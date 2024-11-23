import NIOHTTP1
import Foundation

struct GetImageHistoryEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = [ImageLayer]
	var method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] { [] }

	private var nameOrId: String
	
	var path: String {
		"images/\(nameOrId)/history"
	}
	
	init(nameOrId: String) {
		self.nameOrId = nameOrId
	}
}
