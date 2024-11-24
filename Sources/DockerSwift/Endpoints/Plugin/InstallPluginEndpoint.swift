import NIOHTTP1
import Foundation

struct InstallPluginEndpoint: SimpleEndpoint {
	typealias Response = NoBody
	typealias Body = [PluginPrivilege]
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] {
		[
			URLQueryItem(name: "remote", value: remote),
			alias.map { URLQueryItem.init(name: "name", value: $0) },
		]
			.compactMap(\.self)
	}

	var path: String {
		"plugins/pull"
	}
	var headers: HTTPHeaders? = nil
	var body: Body?
	
	private let remote: String
	private let alias: String?
	private let token: RegistryAuth.Token?

	init(remote: String, alias: String?, privileges: [PluginPrivilege]?, token: RegistryAuth.Token?) {
		self.body = privileges ?? []
		self.remote = remote
		self.alias = alias
		self.token = token
		if let token {
			self.headers = .init([("X-Registry-Auth", token.rawValue)])
		}
	}
}
