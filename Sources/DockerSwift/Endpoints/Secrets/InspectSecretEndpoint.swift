import Foundation
import NIOHTTP1

struct InspectSecretEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = Secret
	let method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] { [] }

	private let nameOrId: String
	
	init(nameOrId: String) {
		self.nameOrId = nameOrId
	}
	
	var path: String {
		"secrets/\(nameOrId)"
	}
}
