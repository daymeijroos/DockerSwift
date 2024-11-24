import Foundation
import NIOHTTP1

struct ListServicesEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = [Service]
	let method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] {
		[URLQueryItem(name: "insertDefaults", value: insertDefaults.description)]
	}

	var insertDefaults: Bool
	init(insertDefaults: Bool = true) {
		self.insertDefaults = insertDefaults
	}
	
	var path: String {
		"services"
	}
}
