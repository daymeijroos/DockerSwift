import Foundation
import NIOHTTP1

struct InspectPluginEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = Plugin
	let method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] { [] }

	private let name: String
	
	init(name: String) {
		self.name = name
	}
	
	var path: String {
		"plugins/\(name)/json"
	}
}
