import Foundation
import NIOHTTP1

struct DeleteNodeEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = NoBody
	let method: HTTPMethod = .DELETE
	var queryArugments: [URLQueryItem] {
		[URLQueryItem(name: "force", value: force.description)]
	}

	let id: String
	let force: Bool
	
	init(id: String, force: Bool) {
		self.id = id
		self.force = force
	}
	
	var path: String {
		"nodes/\(id)"
	}
}
