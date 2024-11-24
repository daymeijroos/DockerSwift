import NIOHTTP1
import Foundation

struct DisconnectContainerEndpoint: SimpleEndpoint {
	typealias Body = DisconnectContainerRequest
	
	typealias Response = NoBody?
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] { [] }

	private let nameOrId: String
	
	var body: Body?
	
	init(nameOrId: String, containerNameOrId: String, force: Bool) {
		self.nameOrId = nameOrId
		self.body = .init(Container: containerNameOrId, Force: force)
	}
	
	var path: String {
		"networks/\(nameOrId)/disconnect"
	}
	
	struct DisconnectContainerRequest: Codable {
		let Container: String
		let Force: Bool
	}
}
