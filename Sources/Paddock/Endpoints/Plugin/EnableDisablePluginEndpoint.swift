import NIOHTTP1
import Foundation

struct EnableDisablePluginEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	
	typealias Response = NoBody?
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] {
		[URLQueryItem(name: "timeout", value: timeout.description)]
	}

	private let name: String
	// if `false`, will disable
	private let enable: Bool
	let timeout: Int

	init(name: String, enable: Bool, timeout: Int = 30) {
		self.name = name
		self.enable = enable
		self.timeout = timeout
	}
	
	var path: String {
		"plugins/\(name)/\(enable ? "enable" : "disable")"
	}
}
