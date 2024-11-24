import NIOHTTP1
import Foundation

struct CreateSecretEndpoint: SimpleEndpoint {
	var body: Body?
	
	typealias Response = CreateSecretResponse
	typealias Body = SecretSpec
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] { [] }

	var path: String {
		"secrets/create"
	}
	
	init(spec: SecretSpec) {
		self.body = spec
	}
	
	struct CreateSecretResponse: Codable {
		let ID: String
	}
}
