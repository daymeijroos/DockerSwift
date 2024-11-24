import NIOHTTP1
import Foundation

struct ConfigurePluginEndpoint: SimpleEndpoint {
	typealias Response = NoBody
	typealias Body = [String]
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] { [] }

	var path: String {
		"plugins/\(name)/set"
	}
	var headers: HTTPHeaders? = nil
	var body: Body?
	
	private let name: String
	
	init(name: String, config: [String]) {
		self.body = config
		self.name = name
		
	}
}
