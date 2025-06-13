import NIOHTTP1
import Foundation
import BetterCodable

public struct GetImageHistoryEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	public typealias Response = [ImageLayer]
	let method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] { [] }

	private var nameOrId: String
	
	var path: String {
		"images/\(nameOrId)/history"
	}
	
	init(nameOrId: String) {
		self.nameOrId = nameOrId
	}
}

public extension GetImageHistoryEndpoint {
	/// Information about an `Image` layer returned by the image History endpoint.
	struct ImageLayer: Codable {
		public let id: String

		@DateValue<TimestampStrategy>
		private(set) public var createdAt: Date

		/// Dockerfile step that generated this layer
		public let createdBy: String

		public let tags: [String]?

		/// Size of this layer, in bytes
		public let size: UInt64

		public let comment: String

		enum CodingKeys: String, CodingKey {
			case id = "Id"
			case createdAt = "Created"
			case createdBy = "CreatedBy"
			case tags = "Tags"
			case size = "Size"
			case comment = "Comment"
		}
	}
}
