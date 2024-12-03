@testable import Paddock
import AsyncHTTPClient
import NIO

extension ContainerAttachEndpoint: BidirectionalMockEndpoint {

	public var responseData: [MockedResponseData] {
		[
			.base64EncodedString("SFRUUC8xLjEgMjAwIE9LDQpDb250ZW50LVR5cGU6IGFwcGxpY2F0aW9uL3ZuZC5kb2NrZXIucmF3LXN0cmVhbQ0KDQo=")
		]
	}

	public var reactiveData: [ByteBuffer: [MockedResponseData]] {
		[
			MockedResponseData.string(#"echo "fizz buzz""# + "\n").data: [
				.string(#"echo "fizz"#),
				.string(#" buzz""# + "\r\n"),
				.string("fizz buzz\r\n"),
				.base64EncodedString("LyAjIBtbNg=="),
			]
		]
	}

	public func send(_ buffer: ByteBuffer) async throws {
		guard
			buffer != ByteBuffer(string: "exit")
		else {
			streamContinuation?.finish()
			return
		}

		guard
			let responses = reactiveData[buffer]
		else {
			let error = DockerError.message("Unknown command")
			streamContinuation?.finish(throwing: error)
			throw error
		}

		for response in responses {
			try await Task.sleep(for: .milliseconds(3))
			streamContinuation?.yield(response.data)
		}
	}

	public mutating func mockedStreamingResponse(_ request: HTTPClientRequest) async throws -> AsyncThrowingStream<ByteBuffer, any Error> {
		let (stream, continuation) = AsyncThrowingStream<ByteBuffer, Error>.makeStream()

		self.streamContinuation = continuation

		Task { [responseData] in
			for response in responseData {
				try await Task.sleep(for: .milliseconds(3))
				continuation.yield(response.data)
			}
		}
		return stream
	}
}
