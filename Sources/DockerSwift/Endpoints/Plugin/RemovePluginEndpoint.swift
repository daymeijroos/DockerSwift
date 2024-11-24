import NIOHTTP1
import Foundation

struct RemovePluginEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = NoBody?
	var queryArugments: [URLQueryItem] {
		[
			URLQueryItem(name: "force", value: force.description)
		]
	}

	let method: HTTPMethod = .DELETE
	var path: String {
		"plugins/\(name)"
	}
	
	private let name: String
	private let force: Bool
	
	init(name: String, force: Bool) {
		self.name = name
		self.force = force
	}
}
