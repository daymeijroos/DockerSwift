import NIOHTTP1
import Foundation

struct CreateConfigEndpoint: SimpleEndpoint {
	var body: Body?
	
	typealias Response = CreateConfigResponse
	typealias Body = ConfigSpec
	let method: HTTPMethod = .POST

	var queryArugments: [URLQueryItem] { [] }

	init(spec: ConfigSpec) {
		self.body = spec
	}
	
	var path: String {
		"configs/create"
	}
	
	struct CreateConfigResponse: Codable {
		let ID: String
	}
}
