import NIOHTTP1
import Foundation

struct ListContainersEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = [ContainerSummary]
	var method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] {
		[URLQueryItem(name: "all", value: "\(all)")]
	}

	private var all: Bool
	
	init(all: Bool) {
		self.all = all
	}
	
	var path: String {
		"containers/json"
	}
}
