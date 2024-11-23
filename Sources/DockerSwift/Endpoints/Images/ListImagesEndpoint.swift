import NIOHTTP1
import Foundation

struct ListImagesEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = [ImageSummary]
	var method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] {
		[URLQueryItem(name: "all", value: all.description)]
	}

	private var all: Bool
	
	init(all: Bool) {
		self.all = all
	}
	
	var path: String {
		"images/json"
	}
}
