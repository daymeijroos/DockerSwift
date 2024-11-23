@testable import DockerSwift
import NIO

extension TagImageEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.rawData(ByteBuffer())
		]
	}
}
