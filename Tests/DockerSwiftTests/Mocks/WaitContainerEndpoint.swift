@testable import DockerSwift
import AsyncHTTPClient
import NIO

extension WaitContainerEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.string(#"{"StatusCode":0,"Error":null}"#),
		]
	}

	public func mockedResponse(_ request: HTTPClientRequest) async throws -> ByteBuffer {
		try await superMockedResponse(request, sleepDelay: Duration.milliseconds(100))
	}
}
