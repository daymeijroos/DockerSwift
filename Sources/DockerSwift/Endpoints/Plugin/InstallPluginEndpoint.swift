import NIOHTTP1
import Foundation

struct InstallPluginEndpoint: SimpleEndpoint {
	typealias Response = NoBody
	typealias Body = [PluginPrivilege]
	var method: HTTPMethod = .POST
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
	private let credentials: RegistryAuth?
	
	init(remote: String, alias: String?, privileges: [PluginPrivilege]?, credentials: RegistryAuth?) {
		self.body = privileges ?? []
		self.remote = remote
		self.alias = alias
		self.credentials = credentials
		if let credentials = credentials, let token = credentials.token {
			self.headers = .init([("X-Registry-Auth", token)])
		}
	}
}
