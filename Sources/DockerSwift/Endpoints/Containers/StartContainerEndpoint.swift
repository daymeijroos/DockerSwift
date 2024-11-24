import NIOHTTP1
import Foundation

struct StartContainerEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	
	typealias Response = NoBody?
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] { [] }

	private let containerId: String
	
	init(containerId: String) {
		self.containerId = containerId
	}
	
	var path: String {
		"containers/\(containerId)/start"
	}
}
