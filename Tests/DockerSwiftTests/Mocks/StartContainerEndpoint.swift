@testable import DockerSwift
import NIO

extension StartContainerEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.rawData(ByteBuffer())
		]
	}
}
