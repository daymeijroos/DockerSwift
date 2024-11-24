import NIOHTTP1
import Foundation

struct CreateNetworkEndpoint: SimpleEndpoint {
	var body: Body?
	
	typealias Response = CreateNetworkResponse
	typealias Body = NetworkSpec
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] { [] }

	init(spec: NetworkSpec) {
		self.body = spec
	}
	
	var path: String {
		"networks/create"
	}
	
	struct CreateNetworkResponse: Codable {
		let Id: String
		let Warning: String?
	}
}
