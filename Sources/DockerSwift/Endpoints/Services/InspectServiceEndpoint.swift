import Foundation
import NIOHTTP1

struct InspectServiceEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = Service
	var method: HTTPMethod = .GET
	
	private let nameOrId: String
	
	init(nameOrId: String) {
		self.nameOrId = nameOrId
	}
	
	var path: String {
		"services/\(nameOrId)?insertDefaults=true"
	}
}
