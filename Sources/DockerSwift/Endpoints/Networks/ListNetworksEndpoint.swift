import Foundation
import NIOHTTP1

struct ListNetworksEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = [Network]
	var method: HTTPMethod = .GET
	
	init() {
	}
	
	var path: String {
		"networks"
	}
}
