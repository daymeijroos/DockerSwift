import NIO
import NIOHTTP1

struct RemoveContainerEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	
	typealias Response = NoBody?
	var method: HTTPMethod = .DELETE
	
	private let containerId: String
	private let force: Bool
	private let removeAnonymousVolumes: Bool
	
	init(containerId: String, force: Bool, removeAnonymousVolumes: Bool) {
		self.containerId = containerId
		self.force = force
		self.removeAnonymousVolumes = removeAnonymousVolumes
	}
	
	var path: String {
		"containers/\(containerId)?force=\(force)&v=\(removeAnonymousVolumes)"
	}
}

extension RemoveContainerEndpoint: MockedResponseEndpoint {
	var responseData: [MockedResponseData] {
		[
			.rawData(ByteBuffer())
		]
	}
}
