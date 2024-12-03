import NIOHTTP1
import Foundation

public struct RemoveImageEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	
	let method: HTTPMethod = .DELETE
	var queryArugments: [URLQueryItem] {
		[
			URLQueryItem(name: "force", value: force.description)
		]
	}
	var path: String {
		"images/\(nameOrId)"
	}
	
	private let nameOrId: String
	private let force: Bool
	
	init(nameOrId: String, force: Bool=false) {
		self.nameOrId = nameOrId
		self.force = force
	}

	public typealias Response = [RemovedResult]
}

public extension RemoveImageEndpoint {
	enum RemovedResult: Codable, Sendable, Hashable {
		case deleted(String)
		case untagged(String)

		public init(from decoder: any Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)

			guard
				let onlyKey = container.allKeys.first
			else { throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No matching key found for \(RemovedResult.self)")) }

			switch onlyKey {
			case .deleted:
				let value = try container.decode(String.self, forKey: .deleted)
				self = .deleted(value)
			case .untagged:
				let value = try container.decode(String.self, forKey: .untagged)
				self = .untagged(value)
			}
		}

		enum CodingKeys: String, CodingKey {
			case deleted = "Deleted"
			case untagged = "Untagged"
		}
	}
}
