import NIOHTTP1
import Foundation

public struct PruneVolumesEndpoint: SimpleEndpoint {
	var body: Body?
	var queryArugments: [URLQueryItem] { [] }

	typealias Body = NoBody
	let method: HTTPMethod = .POST

	var path: String {
		"volumes/prune"
	}
}

public extension PruneVolumesEndpoint {
	struct Response: Codable {
		/// The **names** of the volumes that got deleted.
		let volumesDeleted: [String]

		/// The space the was freed, in bytes
		let spaceReclaimed: UInt64

		enum CodingKeys: String, CodingKey {
			case volumesDeleted = "VolumesDeleted"
			case spaceReclaimed = "SpaceReclaimed"
		}
	}
}
