import AsyncHTTPClient
import Foundation
import NIO
import NIOHTTP1
import Logging

class MockingClient: SocketClient {
	let eventLoopGroup: any EventLoopGroup

	init(eventLoopGroupProvider: HTTPClient.EventLoopGroupProvider) {
		switch eventLoopGroupProvider {
		case .shared(let eventLoopGroup):
			self.eventLoopGroup = eventLoopGroup
		case .createNew:
			self.eventLoopGroup = HTTPClient.defaultEventLoopGroup
		}
	}

	func syncShutdown() throws {}
	func shutdown() async throws {}

	func execute(
		_ method: HTTPMethod,
		daemonURL: URL,
		urlPath: String,
		body: HTTPClient.Body?,
		deadline: NIODeadline?,
		logger: Logger,
		headers: HTTPHeaders
	) -> EventLoopFuture<HTTPClient.Response> {
		fatalError()
	}

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
	) async throws -> AsyncThrowingStream<ByteBuffer, any Error> {
		fatalError()
	}
}
