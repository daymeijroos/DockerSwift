import Foundation
import NIO
import NIOHTTP1
import NIOHTTP2
import NIOSSL
import AsyncHTTPClient
import Logging

extension HTTPClient {
	func executeStream(request: HTTPClientRequest, timeout: TimeAmount, logger: Logger) async throws -> (HTTPHeaders, AsyncThrowingStream<ByteBuffer, Error>) {
		var newLogger = Logger(label: "🔌 AsyncHttpClient")
		newLogger.logLevel = logger.logLevel

		let response = try await self.execute(request, timeout: timeout, logger: newLogger)
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

		return (response.headers, stream)
	}
}
