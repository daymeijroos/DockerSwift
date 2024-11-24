import Foundation
import NIOHTTP1
import Logging

struct InspectContainerEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = Container
	let method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] { [] }

	let nameOrId: String
	let logger: Logger

	init(nameOrId: String, logger: Logger) {
		self.nameOrId = nameOrId
		self.logger = logger
	}

	var path: String {
		"containers/\(nameOrId)/json"
	}
}
