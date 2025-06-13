import NIOHTTP1
import Foundation

public struct PruneNetworksEndpoint: SimpleEndpoint {
	var body: Body?

	typealias Body = NoBody
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] { [] }

	var path: String {
		"networks/prune"
	}

	public struct Response: Codable {
		public let networksDeleted: [String]

		enum CodingKeys: String, CodingKey {
			case networksDeleted = "NetworksDeleted"
		}
	}
}
