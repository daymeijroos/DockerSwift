import Foundation
import NIOHTTP1

struct InspectContainerEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = Container
	let method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] { [] }

	let nameOrId: String

	init(nameOrId: String) {
		self.nameOrId = nameOrId
	}

	var path: String {
		"containers/\(nameOrId)/json"
	}
}
