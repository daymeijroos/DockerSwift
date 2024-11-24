import Foundation
import NIOHTTP1

struct InspectTaskEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = SwarmTask
	let method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] { [] }

	private let id: String
	
	init(id: String) {
		self.id = id
	}
	
	var path: String {
		"tasks/\(id)"
	}
}
