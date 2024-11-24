import Foundation
import NIOHTTP1

struct ContainerTopEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = ContainerTop
	let method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] {
		[URLQueryItem(name: "ps_args", value: psArgs)]
	}

	let nameOrId: String
	let psArgs: String
	
	var path: String {
		"containers/\(nameOrId)/"
	}
	
	init(nameOrId: String, psArgs: String) {
		self.nameOrId = nameOrId
		self.psArgs = psArgs
	}
}
