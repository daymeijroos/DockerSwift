import NIOHTTP1
import Foundation

struct PushImageEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = NoBody
	var method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] {
		[
			tag.map { URLQueryItem(name: "tag", value: $0) }
		]
			.compactMap(\.self)
	}

	let nameOrId: String
	let tag: String?
	let credentials: RegistryAuth?
	
	var path: String {
		"images/\(nameOrId)/push"
	}
	
	var headers: HTTPHeaders? = nil
	
	init(nameOrId: String, tag: String? = nil, credentials: RegistryAuth?) {
		self.nameOrId = nameOrId
		self.tag = tag
		self.credentials = credentials
		if let credentials = credentials, let token = credentials.token {
			self.headers = .init([("X-Registry-Auth", token)])
		}
	}
}
