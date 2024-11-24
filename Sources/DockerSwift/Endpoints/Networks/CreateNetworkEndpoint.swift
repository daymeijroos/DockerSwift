import NIOHTTP1
import Foundation

public struct CreateNetworkEndpoint: SimpleEndpoint {
	var body: Body?
	
	typealias Body = NetworkSpec
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] { [] }

	init(spec: NetworkSpec) {
		self.body = spec
	}
	
	var path: String {
		"networks/create"
	}
	
	public struct Response: Codable {
		let id: String
		let warning: String?

		enum CodingKeys: String, CodingKey {
			case id = "Id"
			case warning = "Warning"
		}
	}
}
