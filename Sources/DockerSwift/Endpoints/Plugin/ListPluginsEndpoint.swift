import Foundation
import NIOHTTP1

struct ListPluginsEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = [Plugin]
	var method: HTTPMethod = .GET
	
	init() {}
	
	var path: String {
		"plugins"
	}
}
