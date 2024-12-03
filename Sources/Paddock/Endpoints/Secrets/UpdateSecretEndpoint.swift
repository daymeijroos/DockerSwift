import NIOHTTP1
import Foundation

struct UpdateSecretEndpoint: SimpleEndpoint {
	typealias Response = NoBody
	typealias Body = SecretSpec
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] {
		[URLQueryItem(name: "version", value: version.description)]
	}

	var body: Body?
	
	private let nameOrId: String
	private let version: UInt64
	
	init(nameOrId: String, version: UInt64, spec: SecretSpec) {
		self.nameOrId = nameOrId
		self.version = version
		self.body = spec
	}
	
	var path: String {
		"secrets/\(nameOrId)/update"
	}
}
