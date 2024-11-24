import NIOHTTP1
import Foundation

public struct InitSwarmEndpoint: SimpleEndpoint {
	var body: Body?
	
	typealias Body = SwarmConfig
	typealias Response = String
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] { [] }

	var path: String {
		"swarm/init"
	}
 
	init(config: SwarmConfig) {
		self.body = config
	}
}
