import NIOHTTP1
import Foundation

public struct CreateConfigEndpoint: SimpleEndpoint {
	var body: Body?
	
	typealias Body = ConfigSpec
	let method: HTTPMethod = .POST

	var queryArugments: [URLQueryItem] { [] }

	init(spec: ConfigSpec) {
		self.body = spec
	}
	
	var path: String {
		"configs/create"
	}
	
	public struct Response: Codable {
		let id: String

		enum CodingKeys: String, CodingKey {
			case id = "ID"
		}
	}
}
