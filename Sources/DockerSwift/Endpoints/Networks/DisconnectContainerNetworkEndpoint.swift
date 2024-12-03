import NIOHTTP1
import Foundation

struct DisconnectContainerNetworkEndpoint: SimpleEndpoint {
	typealias Response = NoBody?
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] { [] }

	private let nameOrId: String
	
	var body: Body?
	
	init(nameOrId: String, containerNameOrId: String, force: Bool) {
		self.nameOrId = nameOrId
		self.body = .init(container: containerNameOrId, force: force)
	}
	
	var path: String {
		"networks/\(nameOrId)/disconnect"
	}
	
	struct Body: Codable {
		let container: String
		let force: Bool

		enum CodingKeys: String, CodingKey {
			case container = "Container"
			case force = "Force"
		}
	}
}
