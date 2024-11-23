import NIOHTTP1
import Foundation

struct CreateServiceEndpoint: SimpleEndpoint {
	var body: Body?
	
	typealias Response = CreateServiceResponse
	typealias Body = ServiceSpec
	var method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] { [] }

	init(spec: ServiceSpec) {
		self.body = spec
	}
	
	var path: String {
		"services/create"
	}
	
	struct CreateServiceResponse: Codable {
		let ID: String
	}
}
