import Foundation
import NIOHTTP1

struct WaitContainerEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = ContainerWaitResponse
	var method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] { [] }

	let nameOrId: String
	
	init(nameOrId: String) {
		self.nameOrId = nameOrId
	}
	
	var path: String {
		"containers/\(nameOrId)/wait"
	}
	
	struct ContainerWaitResponse: Codable {
		let StatusCode: Int
	}
}
