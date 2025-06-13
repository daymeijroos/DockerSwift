import NIOHTTP1
import Foundation

struct RenameContainerEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	
	typealias Response = NoBody?
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] {
		[URLQueryItem(name: "name", value: newName)]
	}

	private let containerId: String
	private let newName: String
	
	init(containerId: String, newName: String) {
		self.containerId = containerId
		self.newName = newName
	}
	
	var path: String {
		"containers/\(containerId)/rename"
	}
}
