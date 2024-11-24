import NIOHTTP1
import Foundation

public struct LeaveSwarmEndpoint: SimpleEndpoint {
	
	typealias Body = NoBody
	typealias Response = NoBody
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] {
		[URLQueryItem(name: "force", value: force.description)]
	}

	var path: String {
		"swarm/leave"
	}
	
	private let force: Bool
	
	init(force: Bool = false) {
		self.force = force
	}
}
