import Foundation
import NIOHTTP1

public struct ListVolumesEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	let method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] { [] }

	var path: String { "volumes" }

	public struct Response: Codable {
		public let volumes: [Volume]
		public let warnings: [String]?

		enum CodingKeys: String, CodingKey {
			case volumes = "Volumes"
			case warnings = "Warnings"
		}
	}
}
