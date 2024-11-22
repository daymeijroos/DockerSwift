@testable import DockerSwift

extension PingEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[.string("OK")]
	}
}
