import Foundation
import NIOHTTP1

public struct GetContainerChangesEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	public typealias Response = [Change]
	let method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] { [] }

	let nameOrId: String
	
	init(nameOrId: String) {
		self.nameOrId = nameOrId
	}
	
	var path: String {
		"containers/\(nameOrId)/changes/json"
	}
}

public extension GetContainerChangesEndpoint {
	struct Change: Codable {
		/// Path to file that has changed
		public let path: String

		public let kind: FsChangeKind

		enum CodingKeys: String, CodingKey {
			case path = "Path"
			case kind = "Kind"
		}

		public enum FsChangeKind: Int, Codable {
			case modified = 0
			case added = 1
			case deleted = 2
		}
	}
}
