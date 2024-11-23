import NIOHTTP1
import Foundation

struct RemoveImageEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	
	typealias Response = NoBody?
	var method: HTTPMethod = .DELETE
	var queryArugments: [URLQueryItem] {
		[
			URLQueryItem(name: "force", value: force.description)
		]
	}
	var path: String {
		"images/\(nameOrId)"
	}
	
	private let nameOrId: String
	private let force: Bool
	
	init(nameOrId: String, force: Bool=false) {
		self.nameOrId = nameOrId
		self.force = force
	}
}
