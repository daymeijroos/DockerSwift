import Foundation
import NIOHTTP1

struct InspectServiceEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = Service
	let method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] {
		[
			URLQueryItem(name: "insertDefaults", value: insertDefaults.description)
		]
	}

	private let nameOrId: String
	var insertDefaults: Bool

	init(nameOrId: String, insertDefaults: Bool = true) {
		self.nameOrId = nameOrId
		self.insertDefaults = insertDefaults
	}
	
	var path: String {
		"services/\(nameOrId)"
	}
}
