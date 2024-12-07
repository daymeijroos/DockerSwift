import Foundation
import NIO
import NIOHTTP1
import NIOSSL
import AsyncHTTPClient
import Logging

/// The entry point for Docker/Podman client commands.
public class PaddockClient: @unchecked Sendable {
	internal let apiVersion = "v1.41"
	let headers = HTTPHeaders([
		("Host", "localhost"), // Required by Docker
		("Accept", "application/json;charset=utf-8"),
		("Content-Type", "application/json")
	])
	let decoder = JSONDecoder()
	let encoder = JSONEncoder()

	let socketURL: URL
	let tlsConfig: TLSConfiguration?
	let client: HTTPClient
	let logger: Logger

	package let testMode: TestMode

	public private(set) var state: State = .uninitialized

	/// Initialize the `DockerClient`.
	/// - Parameters:
	///   - socketURL: The URL where the Docker API is listening on. Default is `http+unix:///var/run/docker.sock`.
	///   - tlsConfig: `TLSConfiguration` for a Docker daemon requiring TLS authentication. Default is `nil`.
	///   - logger: `Logger` for the `DockerClient`. Default is `.init(label: "docker-client")`.
	///   - clientThreads: Number of threads to use for the HTTP client EventLoopGroup. Defaults to 2.
	///   - timeout: Pass custom connect and read timeouts via a `HTTPClient.Configuration.Timeout` instance
	///   - proxy: Proxy settings, defaults to `nil`.
	public convenience init(
		socketURL: URL = URL(httpURLWithSocketPath: DockerEnvironment.dockerHost)!,
		tlsConfig: TLSConfiguration? = nil,
		logger: Logger = .init(label: "🪵docker-client"),
		clientThreads: Int = 2,
		timeout: HTTPClient.Configuration.Timeout = .init(),
		proxy: HTTPClient.Configuration.Proxy? = nil
	) {
		self.init(
			socketURL: socketURL,
			tlsConfig: tlsConfig,
			logger: logger,
			clientThreads: clientThreads,
			timeout: timeout,
			proxy: proxy,
			testMode: .live)
	}

	package static func forTesting(
		socketURL: URL = URL(httpURLWithSocketPath: DockerEnvironment.dockerHost)!,
		tlsConfig: TLSConfiguration? = nil,
		clientThreads: Int = 2,
		timeout: HTTPClient.Configuration.Timeout = .init(),
		proxy: HTTPClient.Configuration.Proxy? = nil,
		useLiveSocket: Bool = false
	) -> PaddockClient {
		var logger = Logger(label: "🪵docker-client-tests")
		logger.logLevel = .debug

		return PaddockClient(
			socketURL: socketURL,
			tlsConfig: tlsConfig,
			logger: logger,
			clientThreads: clientThreads,
			timeout: timeout,
			proxy: proxy,
			testMode: .testing(useMocks: !useLiveSocket))
	}

	private init(
		socketURL: URL = URL(httpURLWithSocketPath: DockerEnvironment.dockerHost)!,
		tlsConfig: TLSConfiguration? = nil,
		logger: Logger = .init(label: "🪵docker-client"),
		clientThreads: Int = 2,
		timeout: HTTPClient.Configuration.Timeout = .init(),
		proxy: HTTPClient.Configuration.Proxy? = nil,
		testMode: TestMode
	) {
		self.socketURL = socketURL
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
		self.testMode = testMode
	}

	@MainActor
	private func _initialize(with headers: HTTPHeaders) throws {
		guard case .uninitialized = state else { return }

		let hostInfo = try HostInfo(from: headers)
		self.state = .initialized(hostInfo)
	}

	/// The client needs to be shutdown otherwise it can crash on exit.
	/// - Throws: Throws an error if the `DockerClient` can not be shutdown.
	public func syncShutdown() throws {
		defer { state = .uninitialized }
		try client.syncShutdown()
	}
	
	/// The client needs to be shutdown otherwise it can crash on exit.
	/// - Throws: Throws an error if the `DockerClient` can not be shutdown.
	public func shutdown() async throws {
		defer { state = .uninitialized }
		try await client.shutdown()
	}

	/// Executes a request to a specific endpoint that is a single, simple operation. Call and response. No streaming.
	@discardableResult
	internal func run<T: SimpleEndpoint>(_ endpoint: T) async throws -> T.Response {
		defer {
			if logger.logLevel <= .debug {
				// printing to avoid the logging prefix, making for an easier copy/pasta
				try? print("💻⭐️\n\(genCurlCommand(endpoint))\n")
			}
		}

		let request = try endpoint.request(
			socketURL: socketURL,
			apiVersion: apiVersion,
			additionalHeaders: headers,
			encoder: encoder)

		func decodeOut(_ buffer: ByteBuffer) throws -> T.Response {
			if T.Response.self == NoBody.self || T.Response.self == NoBody?.self {
				return NoBody() as! T.Response
			}
			guard T.Response.self != String.self else {
				return String(buffer: buffer) as! T.Response
			}
			let contingencyBuffer = buffer
			do {
				let decodedResponse = try decoder.decode(T.Response.self, from: buffer)
				try endpoint.responseValidation(decodedResponse)
				return decodedResponse
			} catch {
				throw DockerError.unexpectedResponse(contingencyBuffer, "Could not decode or validate response.")
			}
		}

		if case .testing(useMocks: let useMocks) = testMode {
			do {
				return try await performTest(useMocks: useMocks, endpoint: endpoint) { mockEndpoint in
					try mockEndpoint.validate(request: request)
					let buffer = try await mockEndpoint.mockedResponse(request)
					return try decodeOut(buffer)
				}
			} catch is NoMockAvailableError {}
		}

		let response = try await client.execute(request, timeout: endpoint.timeout ?? .minutes(2))
		let responseBody = response.body
		try await _initialize(with: response.headers)
		try response.checkStatusCode()

		let buffer = try await responseBody.collect(upTo: .max)

		if logger.logLevel <= .debug {
			var debugResponseCopy = buffer
			logger.debug("Response: \(debugResponseCopy.readString(length: debugResponseCopy.readableBytes) ?? "No Response Data")")
		}
		return try decodeOut(buffer)
	}
	
	/// Run an endpoint that is streaming, but the stream is only ancilary to the purpose of the endpoint. For example
	/// The pull image endpoint. The final, pulled image id is the final purpose, but the stream keeps you apprised to
	/// updates in the meantime. `progressUpdater` is run as data is provided, but the final result is returned after the
	/// stream is completed.
	@discardableResult
	internal func run<T: PipelineEndpoint>(_ endpoint: T, progressUpdater: @escaping (T.Response) -> Void) async throws -> T.FinalResponse {
		let responseStream = try await run(endpoint)

		var accumulator: [T.Response] = []
		for try await response in responseStream {
			progressUpdater(response)
			accumulator.append(response)
		}

		return try await endpoint.finalize(accumulator)
	}

	/// Run an endpoint that streams data. Log updates might be a good example.
	@discardableResult
	internal func run<T: StreamingEndpoint>(_ endpoint: T, timeout: TimeAmount? = nil) async throws -> AsyncThrowingStream<T.Response, Error> {
		defer {
			if logger.logLevel <= .debug {
				// printing to avoid the logging prefix, making for an easier copy/pasta
				try? print("💻⭐️\n\(genCurlCommand(endpoint))\n")
			}
		}

		let request = try endpoint.request(
			socketURL: socketURL,
			apiVersion: apiVersion,
			additionalHeaders: headers,
			encoder: encoder)

		func consumeStream(_ stream: AsyncThrowingStream<ByteBuffer, Error>) -> AsyncThrowingStream<T.Response, Error> {
			let (responseStream, responseContinuation) = AsyncThrowingStream<T.Response, Error>.makeStream()
			Task {
				do {
					var chunkyBuffer = ByteBuffer()
					for try await var buffer in stream {
						chunkyBuffer.writeBuffer(&buffer)

						do throws(StreamChunkError) {
							var remaining = ByteBuffer()
							defer { chunkyBuffer = remaining }
							let results = try await endpoint.mapStreamChunk(chunkyBuffer, remainingBytes: &remaining)
							for result in results {
								responseContinuation.yield(result)
							}
						} catch {
							switch error {
							case .noValidData:
								continue
							case .decodeError(let error):
								responseContinuation.finish(throwing: error)
							}
						}
					}
					responseContinuation.finish()
				} catch {
					responseContinuation.finish(throwing: error)
				}
			}
			return responseStream
		}

		if case .testing(useMocks: let useMocks) = testMode {
			do {
				return try await performTest(useMocks: useMocks, endpoint: endpoint) { mockEndpoint in
					try mockEndpoint.validate(request: request)
					let mockStream = try await mockEndpoint.mockedStreamingResponse(request)
					return consumeStream(mockStream)
				}
			} catch is NoMockAvailableError {}
		}

		let (headers, stream) = try await client.executeStream(request: request, timeout: timeout ?? endpoint.timeout ?? .hours(1), logger: logger)
		try await _initialize(with: headers)

		return consumeStream(stream)
	}

	private struct NoMockAvailableError: Error {}
	private func performTest<EP: Endpoint, T>(useMocks: Bool, endpoint: EP, mockBlock: (any MockedResponseEndpoint) async throws -> T) async throws -> T {
		if useMocks {
			if let mockEndpoint = endpoint as? (any MockedResponseEndpoint) {
				try await _initialize(with: type(of: mockEndpoint).podmanHeaders)
				logger.debug("(\(EP.self) / \(EP.Response.self)) 🍀🍀 Mocked \(endpoint.method.rawValue) \(endpoint.path)")
				return try await mockBlock(mockEndpoint)
			} else {
				logger.debug("(\(EP.self) / \(EP.Response.self)) 🤬🥵 Not Mocked \(endpoint.method.rawValue) \(endpoint.path)")
			}
		} else {
			let isMockStr = (endpoint is any MockedResponseEndpoint) ? "(🍀 mock available)" : "(🥵 no mock available)"
			logger.debug("(\(EP.self) / \(EP.Response.self)) ⚡️🔌 Live Socket Testing \(isMockStr) \(endpoint.method.rawValue) \(endpoint.path)")
		}
		throw NoMockAvailableError()
	}

	package enum TestMode {
		case live
		case testing(useMocks: Bool)
	}
}

// MARK: - Curl Command
extension PaddockClient {
	func genCurlCommand<E: SimpleEndpoint>(_ endpoint: E) throws -> String {
		try genCurlCommand(
			method: endpoint.method,
			path: endpoint.path,
			queryItems: endpoint.queryArugments,
			headers: endpoint.headers,
			body: endpoint.body)
	}

	func genCurlCommand<E: StreamingEndpoint>(_ endpoint: E) throws -> String {
		try genCurlCommand(
			method: endpoint.method,
			path: endpoint.path,
			queryItems: endpoint.queryArugments,
			headers: nil,
			body: endpoint.body)
	}

	private func genCurlCommand<Body: Codable>(
		method: HTTPMethod,
		path: String,
		queryItems: [URLQueryItem],
		headers: HTTPHeaders?,
		body: Body?
	) throws -> String {
		var finalHeaders: HTTPHeaders = self.headers
		if let additionalHeaders = headers {
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
			if let body = body {
				let data = String(decoding: try encoder.encode(body), as: UTF8.self)
					.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
					.replacingOccurrences(of: "'", with: "\'")
				return "-d '\(data)'"
			} else {
				return nil
			}
		}()
		let url = {
			var new = URL(string: "http://localhost/")!
				.appending(component: "\(apiVersion)")
				.appending(path: path)
			if queryItems.isEmpty == false {
				new
				.append(queryItems: queryItems)
			}
			return new
		}()
		let curlUnixSocket = "${DOCKER_HOST}"
		let curlCommand = """
			curl \
			--unix-socket "\(curlUnixSocket)" \
			"\(url.absoluteString)" \
			-X \(method.rawValue)
			"""

		let final = [curlCommand, curlHeaders, curlBody]
			.compactMap(\.self)
			.joined(separator: " ")
		return final
	}
}
