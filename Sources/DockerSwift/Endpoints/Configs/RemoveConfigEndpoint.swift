import NIOHTTP1
import Foundation

struct RemoveConfigEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	
	typealias Response = NoBody?
	var method: HTTPMethod = .DELETE
	var queryArugments: [URLQueryItem] { [] }

	private let nameOrId: String
	
	init(nameOrId: String) {
		self.nameOrId = nameOrId
	}
	
	var path: String {
		"configs/\(nameOrId)"
	}
}
