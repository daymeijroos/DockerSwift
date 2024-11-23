import NIO
import Foundation
import NIOHTTP1

struct RemoveContainerEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	
	typealias Response = NoBody?
	var method: HTTPMethod = .DELETE
	var queryArugments: [URLQueryItem] {
		[
			URLQueryItem(name: "force", value: force.description),
			URLQueryItem(name: "v", value: removeAnonymousVolumes.description)
		]
	}

	private let containerId: String
	private let force: Bool
	private let removeAnonymousVolumes: Bool
	
	init(containerId: String, force: Bool, removeAnonymousVolumes: Bool) {
		self.containerId = containerId
		self.force = force
		self.removeAnonymousVolumes = removeAnonymousVolumes
	}
	
	var path: String {
		"containers/\(containerId)"
	}
}
