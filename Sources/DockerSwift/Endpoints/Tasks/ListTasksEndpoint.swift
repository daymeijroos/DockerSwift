import Foundation
import NIOHTTP1

struct ListTasksEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = [SwarmTask]
	let method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] { [] }
	
	var path: String {
		"tasks"
	}
}
