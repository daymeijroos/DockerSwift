import NIOHTTP1
import Foundation

struct PruneImagesEndpoint: SimpleEndpoint {
	var body: Body?
	
	typealias Response = PruneImagesResponse
	typealias Body = NoBody
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] {
		let value = ["dangling": ["\(dangling)"]]
		let json = try! JSONEncoder().encode(value)
		let jsonString = String(decoding: json, as: UTF8.self)

		return [URLQueryItem(name: "filters", value: jsonString)]
	}

	private var dangling: Bool
	
	/// Init
	/// - Parameter dangling: When set to `true`, prune only unused *and* untagged images. When set to `false`, all unused images are prune.
	init(dangling: Bool=true) {
		self.dangling = dangling
	}
	
	var path: String {
		"images/prune"
	}

	struct PruneImagesResponse: Codable {
		let ImagesDeleted: [PrunedImageResponse]?
		let SpaceReclaimed: UInt64
		
		struct PrunedImageResponse: Codable {
			let Deleted: String?
			let Untagged: String?
		}
	}
}

