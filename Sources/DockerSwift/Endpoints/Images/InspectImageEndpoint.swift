import Foundation
import NIOHTTP1
import Logging

struct InspectImagesEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = Image
	var method: HTTPMethod = .GET

	let logger: Logger

	let nameOrId: String
	
	init(nameOrId: String, logger: Logger) {
		self.nameOrId = nameOrId
		self.logger = logger
	}
	
	var path: String {
		"images/\(nameOrId)/json"
	}
}
