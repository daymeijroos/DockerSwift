import NIOHTTP1
import Foundation

struct RemoveVolumeEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	
	typealias Response = NoBody?
	let method: HTTPMethod = .DELETE
	var queryArugments: [URLQueryItem] {
		[URLQueryItem(name: "force", value: force.description)]
	}

	private let nameOrId: String
	private let force: Bool
	
	init(nameOrId: String, force: Bool) {
		self.nameOrId = nameOrId
		self.force = force
	}
	
	var path: String {
		"volumes/\(nameOrId)"
	}
}
