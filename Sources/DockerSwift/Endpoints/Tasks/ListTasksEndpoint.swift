import Foundation
import NIOHTTP1

struct ListTasksEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = [SwarmTask]
	var method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] { [] }
	
	var path: String {
		"tasks"
	}
}
