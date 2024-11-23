import Foundation
import NIOHTTP1

struct GetPluginPrivilegesEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = [PluginPrivilege]
	var method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] {
		[URLQueryItem(name: "remote", value: remote)]
	}

	private let remote: String
	
	init(remote: String) {
		self.remote = remote
	}
	
	var path: String {
		"plugins/privileges"
	}
}
