import NIOHTTP1
import Foundation

public struct CreateServiceEndpoint: SimpleEndpoint {
	var body: Body?
	
	typealias Body = ServiceSpec
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] { [] }

	init(spec: ServiceSpec) {
		self.body = spec
	}
	
	var path: String {
		"services/create"
	}
	
	public struct Response: Codable {
		let id: String

		enum CodingKeys: String, CodingKey {
			case id = "ID"
		}
	}
}
