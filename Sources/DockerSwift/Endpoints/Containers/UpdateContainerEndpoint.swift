import NIOHTTP1
import Foundation

struct UpdateContainerEndpoint: SimpleEndpoint {
	var body: ContainerUpdate?
	
	typealias Response = NoBody
	typealias Body = ContainerUpdate
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] { [] }

	private let nameOrId: String
	
	init(nameOrId: String, spec: ContainerUpdate) {
		self.nameOrId = nameOrId
		self.body = spec
	}
	
	var path: String {
		"containers/\(nameOrId)/update"
	}
}
