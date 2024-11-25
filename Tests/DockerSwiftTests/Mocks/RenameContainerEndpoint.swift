@testable import DockerSwift
import NIO

extension RenameContainerEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[.rawData(ByteBuffer())]
	}
}
