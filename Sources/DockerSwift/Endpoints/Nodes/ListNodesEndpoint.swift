import Foundation
import NIOHTTP1

// TODO: add `filters` parameter
struct ListNodesEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = [SwarmNode]
	let method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] { [] }

	var path: String {
		"nodes"
	}
}
