import Foundation
import NIOHTTP1

struct UpdateNodeEndpoint: SimpleEndpoint {
	typealias Body = SwarmNodeSpec
	typealias Response = NoBody
	var method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] {
		[URLQueryItem(name: "version", value: version.description)]
	}

	var body: Body?
	let id: String
	let version: UInt64
	
	init(id: String, version: UInt64, spec: SwarmNodeSpec) {
		self.id = id
		self.version = version
		self.body = spec
	}
	
	var path: String {
		"nodes/\(id)/update"
	}
}
