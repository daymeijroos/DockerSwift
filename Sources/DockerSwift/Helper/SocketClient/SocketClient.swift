import AsyncHTTPClient
import Foundation
import NIO
import NIOHTTP1
import Logging

protocol SocketClient: AnyObject {
	var eventLoopGroup: EventLoopGroup { get }

	func syncShutdown() throws
	func shutdown() async throws

	func execute(
		_ method: HTTPMethod,
		daemonURL: URL,
		urlPath: String,
		body: HTTPClient.Body?,
		deadline: NIODeadline?,
		logger: Logger,
		headers: HTTPHeaders
	) -> EventLoopFuture<HTTPClient.Response>

	func executeStream(
		_ method: HTTPMethod,
		daemonURL: URL,
		urlPath: String,
		body: HTTPClientRequest.Body?,
		timeout: TimeAmount,
		logger: Logger,
		headers: HTTPHeaders,
		hasLengthHeader: Bool,
		separators: [UInt8]
	) async throws -> AsyncThrowingStream<ByteBuffer, Error>
}

extension HTTPClient: SocketClient {}
