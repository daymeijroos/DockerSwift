@testable import Paddock
import NIO

extension RemoveContainerEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.rawData(ByteBuffer())
		]
	}
}
