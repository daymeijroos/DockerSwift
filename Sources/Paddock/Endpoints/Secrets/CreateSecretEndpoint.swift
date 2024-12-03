import NIOHTTP1
import Foundation

public struct CreateSecretEndpoint: SimpleEndpoint {
	var body: Body?
	
	typealias Body = SecretSpec
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] { [] }

	var path: String {
		"secrets/create"
	}
	
	init(spec: SecretSpec) {
		self.body = spec
	}

	public struct Response: Codable {
		let id: String

		enum CodingKeys: String, CodingKey {
			case id = "ID"
		}
	}
}
