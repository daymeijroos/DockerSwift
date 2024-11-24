import NIOHTTP1
import Foundation

struct UpgradePluginEndpoint: SimpleEndpoint {
	typealias Response = NoBody
	typealias Body = [PluginPrivilege]
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] {
		[URLQueryItem(name: "remote", value: remote)]
	}

	var path: String {
		"plugins/\(name)/upgrade"
	}
	var headers: HTTPHeaders? = nil
	var body: Body?
	
	private let name: String
	private let remote: String
	private let token: RegistryAuth.Token?

	init(name: String, remote: String, privileges: [PluginPrivilege]?, token: RegistryAuth.Token?) {
		self.body = privileges ?? []
		self.name = name
		self.remote = remote
		self.token = token
		if let token {
			self.headers = ["X-Registry-Auth": token.rawValue]
		}
	}
}
