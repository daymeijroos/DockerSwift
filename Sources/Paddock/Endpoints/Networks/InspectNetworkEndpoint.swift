import Logging
import Foundation
import NIOHTTP1

struct InspectNetworkEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = Network
	let method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] { [] }

	let nameOrId: String
	let logger: Logger

	init(nameOrId: String, logger: Logger) {
		self.nameOrId = nameOrId
		self.logger = logger
	}
	
	var path: String {
		"networks/\(nameOrId)"
	}
}
