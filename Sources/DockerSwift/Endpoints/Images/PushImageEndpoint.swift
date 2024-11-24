import NIOHTTP1
import Foundation

struct PushImageEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = NoBody
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] {
		[
			tag.map { URLQueryItem(name: "tag", value: $0) }
		]
			.compactMap(\.self)
	}

	let nameOrId: String
	let tag: String?
	let token: RegistryAuth.Token?

	var path: String {
		"images/\(nameOrId)/push"
	}
	
	var headers: HTTPHeaders? = nil
	
	init(nameOrId: String, tag: String? = nil, token: RegistryAuth.Token?) {
		self.nameOrId = nameOrId
		self.tag = tag
		self.token = token
		if let token {
			self.headers = .init([("X-Registry-Auth", token.rawValue)])
		}
	}
}
