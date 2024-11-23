import Foundation
import NIOHTTP1

struct ListPluginsEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = [Plugin]
	var method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] { [] }

	init() {}
	
	var path: String {
		"plugins"
	}
}
