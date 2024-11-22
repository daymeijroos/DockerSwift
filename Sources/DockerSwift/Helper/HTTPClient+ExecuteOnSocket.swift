import Foundation
import NIO
import NIOHTTP1
import NIOHTTP2
import NIOSSL
import AsyncHTTPClient
import Logging

extension HTTPClient {
	/// Executes a HTTP request on a socket.
	/// - Parameters:
	///   - method: HTTP method.
	///   - socketPath: The path to the unix domain socket to connect to.
	///   - urlPath: The URI path and query that will be sent to the server.
	///   - body: Request body.
	///   - deadline: Point in time by which the request must complete.
	///   - logger: The logger to use for this request.
	///   - headers: Custom HTTP headers.
	/// - Returns: Returns an `EventLoopFuture` with the `Response` of the request
	@available(*, deprecated)
	public func execute(_ method: HTTPMethod = .GET, daemonURL: URL, urlPath: String, body: Body? = nil, deadline: NIODeadline? = nil, logger: Logger, headers: HTTPHeaders) -> EventLoopFuture<Response> {
		do {
			guard let url = URL(string: daemonURL.absoluteString.trimmingCharacters(in: .init(charactersIn: "/")) + urlPath) else {
				throw HTTPClientError.invalidURL
			}
			
			let request = try Request(url: url, method: method, headers: headers, body: body)
			return self.execute(request: request, deadline: deadline, logger: logger)
		} catch {
			return self.eventLoopGroup.next().makeFailedFuture(error)
		}
	}
	
	/// Takes care of "pre-parsing" the output of some Docker endpoints returning a stream of data.
	/// Of course these are very inconsistent: sometimes these items have a length prefix, sometimes that are just test separated by newlines, other times they are JSON
	///  objects separated by newlines.
	@available(*, deprecated)
	internal func executeStream(_ method: HTTPMethod = .GET, daemonURL: URL, urlPath: String, body: HTTPClientRequest.Body? = nil, timeout: TimeAmount, logger: Logger, headers: HTTPHeaders, hasLengthHeader: Bool = false, separators: [UInt8]) async throws -> AsyncThrowingStream<ByteBuffer, Error> {
		
		guard let url = URL(string: daemonURL.absoluteString.trimmingCharacters(in: .init(charactersIn: "/")) + urlPath) else {
			throw HTTPClientError.invalidURL
		}
		
		var request = HTTPClientRequest(url: url.absoluteString)
		request.headers = headers
		request.method = method
		request.body = body
		
		let response = try await self.execute(request, timeout: timeout, logger: logger)
		let body = response.body
		let (stream, continuation) = AsyncThrowingStream<ByteBuffer, Error>.makeStream()

		_Concurrency.Task {
			for try await buffer in body {
				continuation.yield(buffer)
			}
			continuation.finish()
		}

		return stream
	}

	func executeStream(request: HTTPClientRequest, timeout: TimeAmount, logger: Logger) async throws -> AsyncThrowingStream<ByteBuffer, Error> {
		let response = try await self.execute(request, timeout: timeout, logger: logger)
		guard
			(200...299).contains(response.status.code)
		else {
			throw DockerError.errorCode(Int(response.status.code), response.status.reasonPhrase)
		}
		let body = response.body

		let (stream, continuation) = AsyncThrowingStream<ByteBuffer, Error>.makeStream()

		_Concurrency.Task {
			do {
				for try await buffer in body {
					if logger.logLevel <= .debug {
						var debugResponseCopy = buffer
						logger.debug("Response: \(debugResponseCopy.readString(length: debugResponseCopy.readableBytes) ?? "No Response Data")")
					}
					continuation.yield(buffer)
				}
			} catch {
				continuation.finish(throwing: error)
				return
			}
			continuation.finish()
		}

		return stream
	}
}
