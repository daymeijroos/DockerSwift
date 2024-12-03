import Foundation
import NIOHTTP1

struct ListNetworksEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = [Network]
	let method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] { [] }
	
	var path: String { "networks" }
}
