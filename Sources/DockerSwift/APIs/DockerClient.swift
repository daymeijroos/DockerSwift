import Foundation
import NIO
import NIOHTTP1
import NIOSSL
import AsyncHTTPClient
import Logging

/// The entry point for Docker client commands.
public class DockerClient {
    internal let apiVersion = "v1.41"
    private let headers = HTTPHeaders([
        ("Host", "localhost"), // Required by Docker
        ("Accept", "application/json;charset=utf-8"),
        ("Content-Type", "application/json")
    ])
    private let decoder: JSONDecoder
    
    internal let daemonURL: URL
    internal let tlsConfig: TLSConfiguration?
    internal let client: HTTPClient
    private let logger: Logger
    
    
    /// Initialize the `DockerClient`.
    /// - Parameters:
    ///   - daemonURL: The URL where the Docker API is listening on. Default is `http+unix:///var/run/docker.sock`.
    ///   - tlsConfig: `TLSConfiguration` for a Docker daemon requiring TLS authentication. Default is `nil`.
    ///   - logger: `Logger` for the `DockerClient`. Default is `.init(label: "docker-client")`.
    ///   - clientThreads: Number of threads to use for the HTTP client EventLoopGroup. Defaults to 2.
    ///   - timeout: Pass custom connect and read timeouts via a `HTTPClient.Configuration.Timeout` instance
    ///   - proxy: Proxy settings, defaults to `nil`.
    public init(
        daemonURL: URL = URL(httpURLWithSocketPath: DockerEnvironment.dockerHost)!,
        tlsConfig: TLSConfiguration? = nil,
        logger: Logger = .init(label: "docker-client"),
        clientThreads: Int = 2,
        timeout: HTTPClient.Configuration.Timeout = .init(),
        proxy: HTTPClient.Configuration.Proxy? = nil
    ) {
        self.daemonURL = daemonURL
        self.tlsConfig = tlsConfig
        let clientConfig = HTTPClient.Configuration(
            tlsConfiguration: tlsConfig,
            timeout: timeout,
            proxy: proxy,
            ignoreUncleanSSLShutdown: true
        )
        let httpClient = HTTPClient(
            eventLoopGroupProvider: .shared(MultiThreadedEventLoopGroup(numberOfThreads: clientThreads)),
            configuration: clientConfig
        )
        self.client = httpClient
        self.logger = logger

        // Docker uses ISO8601 internet variant for returning dates
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = .withInternetDateTime
        formatter.formatOptions.insert(.withFractionalSeconds)

        // create explicit closure to silence annoying warning
        let strat: (any Swift.Decoder) throws -> Date = { decoder in
            let dateStr = try decoder.singleValueContainer().decode(String.self)

            let date = formatter.date(from: dateStr)
            guard let date else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Malformatted date string"))
            }
            return date
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(strat)
        self.decoder = decoder
    }

    /// The client needs to be shutdown otherwise it can crash on exit.
    /// - Throws: Throws an error if the `DockerClient` can not be shutdown.
    public func syncShutdown() throws {
        try client.syncShutdown()
    }
    
    /// The client needs to be shutdown otherwise it can crash on exit.
    /// - Throws: Throws an error if the `DockerClient` can not be shutdown.
    public func shutdown() async throws {
        try await client.shutdown()
    }

    func genCurlCommand<E: Endpoint>(_ endpoint: E) throws -> String {
        var finalHeaders: HTTPHeaders = self.headers
        if let additionalHeaders = endpoint.headers {
            finalHeaders.add(contentsOf: additionalHeaders)
        }

        let curlHeaders: String? = {
            let headers = finalHeaders
                .map { "-H \"\($0.name): \($0.value)\"" }
                .joined(separator: " ")
            guard headers.isEmpty == false else {
                return nil
            }
            return headers
        }()
        let curlBody: String? = try {
            if let body = endpoint.body {
                String(decoding: try body.encode(), as: UTF8.self)
            } else {
                nil
            }
        }()
        let curlUnixSocket = "${DOCKER_HOST}"
        let curlCommand = """
            curl \
            --unix-socket "\(curlUnixSocket)" \
            "http://localhost/\(apiVersion)/\(endpoint.path)" \
            -X \(endpoint.method.rawValue)
            """

        let final = [curlCommand, curlHeaders, curlBody]
            .compactMap(\.self)
            .joined(separator: " ")
        return final
    }

    /// Executes a request to a specific endpoint. The `Endpoint` struct provides all necessary data and parameters for the request.
    /// - Parameter endpoint: `Endpoint` instance with all necessary data and parameters.
    /// - Throws: It can throw an error when encoding the body of the `Endpoint` request to JSON.
    /// - Returns: Returns the expected result definied by the `Endpoint`.
    @discardableResult
    internal func run<T: Endpoint>(_ endpoint: T) async throws -> T.Response {
        logger.debug("\(Self.self) execute Endpoint: \(endpoint.method) \(endpoint.path)")
        var finalHeaders: HTTPHeaders = self.headers
        if let additionalHeaders = endpoint.headers {
            finalHeaders.add(contentsOf: additionalHeaders)
        }
        if logger.logLevel <= .debug {
            // printing to avoid the logging prefix, making for an easier copy/pasta
            try print("\n\(genCurlCommand(endpoint))\n")
        }

        return try await client.execute(
            endpoint.method,
            daemonURL: self.daemonURL,
            urlPath: "/\(apiVersion)/\(endpoint.path)",
            body: endpoint.body.map {HTTPClient.Body.data( try! $0.encode())},
            logger: logger,
            headers: finalHeaders
        )
        .logResponseBody(logger)
        .decode(as: T.Response.self, decoder: self.decoder)
        .get()
    }
    
    /// Executes a request to a specific endpoint. The `PipelineEndpoint` struct provides all necessary data and parameters for the request.
    /// The difference for between `Endpoint` and `EndpointPipeline` is that the second one needs to provide a function that transforms the response as a `String` to the expected result.
    /// - Parameter endpoint: `PipelineEndpoint` instance with all necessary data and parameters.
    /// - Throws: It can throw an error when encoding the body of the `PipelineEndpoint` request to JSON.
    /// - Returns: Returns the expected result definied and transformed by the `PipelineEndpoint`.
    @discardableResult
    internal func run<T: PipelineEndpoint>(_ endpoint: T) async throws -> T.Response {
        logger.debug("\(Self.self) execute PipelineEndpoint: \(endpoint.method) \(endpoint.path)")
        return try await client.execute(
            endpoint.method,
            daemonURL: self.daemonURL,
            urlPath: "/\(apiVersion)/\(endpoint.path)",
            body: endpoint.body.map {HTTPClient.Body.data( try! $0.encode())},
            logger: logger,
            headers: self.headers
        )
        .logResponseBody(logger)
        .mapString(map: endpoint.map(data: ))
        .get()
    }
    
    @discardableResult
    internal func run<T: StreamingEndpoint>(_ endpoint: T, timeout: TimeAmount, hasLengthHeader: Bool, separators: [UInt8]) async throws -> T.Response {
        logger.debug("\(Self.self) execute StreamingEndpoint: \(endpoint.method) \(endpoint.path)")
        let stream = try await client.executeStream(
            endpoint.method,
            daemonURL: self.daemonURL,
            urlPath: "/\(apiVersion)/\(endpoint.path)",
            body: endpoint.body.map {
                HTTPClientRequest.Body.bytes( try! $0.encode())
            },
            timeout: timeout,
            logger: logger,
            headers: self.headers,
            hasLengthHeader: hasLengthHeader,
            separators: separators
        )
        return stream as! T.Response
    }
    
    @discardableResult
    internal func run<T: UploadEndpoint>(_ endpoint: T, timeout: TimeAmount, separators: [UInt8]) async throws -> T.Response {
        logger.debug("\(Self.self) execute \(T.self): \(endpoint.path)")
        let stream = try await client.executeStream(
            endpoint.method,
            daemonURL: self.daemonURL,
            urlPath: "/\(apiVersion)/\(endpoint.path)",
            body: endpoint.body == nil ? nil : .bytes(endpoint.body!),
            timeout: timeout,
            logger: logger,
            headers: self.headers,
            separators: separators
        )
        return stream as! T.Response
    }
}
