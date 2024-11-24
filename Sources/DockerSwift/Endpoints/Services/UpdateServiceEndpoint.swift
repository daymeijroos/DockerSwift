import NIOHTTP1
import Foundation

struct UpdateServiceEndpoint: SimpleEndpoint {
	var body: Body?
	
	typealias Response = NoBody?
	typealias Body = ServiceSpec?
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] {
		[
			URLQueryItem(name: "version", value: version.description),
			URLQueryItem(name: "rollback", value: rollback ? "previous" : nil),
		]
	}

	private let nameOrId: String
	private let version: UInt64
	private let rollback: Bool

	init(nameOrId: String, version: UInt64, spec: ServiceSpec?, rollback: Bool) {
		self.nameOrId = nameOrId
		self.body = spec
		self.rollback = rollback
		self.version = version
	}
	
	var path: String {
		"services/\(nameOrId)/update?version=\(version)&rollback=\(self.rollback ? "previous" : "")"
	}
}

