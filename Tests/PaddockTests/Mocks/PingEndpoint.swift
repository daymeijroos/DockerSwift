@testable import Paddock

extension PingEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[.string("OK")]
	}
}
