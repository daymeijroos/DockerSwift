import Foundation
import NIOHTTP1

struct ListConfigsEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = [Config]
	let method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] { [] }

	var path: String {
		"configs"
	}
}
