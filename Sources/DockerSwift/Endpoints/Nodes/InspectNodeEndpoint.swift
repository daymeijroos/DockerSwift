import Foundation
import NIOHTTP1

struct InspectNodeEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = SwarmNode
	var method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] { [] }

	let id: String
	
	init(id: String) {
		self.id = id
	}
	
	var path: String {
		"nodes/\(id)"
	}
}
