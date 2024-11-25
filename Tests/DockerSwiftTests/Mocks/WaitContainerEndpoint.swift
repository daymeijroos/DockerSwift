@testable import DockerSwift

extension WaitContainerEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.string(#"{"StatusCode":0,"Error":null}"#),
		]
	}
}
