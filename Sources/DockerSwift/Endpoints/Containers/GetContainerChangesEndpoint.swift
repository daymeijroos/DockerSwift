import Foundation
import NIOHTTP1

struct GetContainerChangesEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = [ContainerFsChange]
	let method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] { [] }

	let nameOrId: String
	
	init(nameOrId: String) {
		self.nameOrId = nameOrId
	}
	
	var path: String {
		"containers/\(nameOrId)/changes/json"
	}
}
