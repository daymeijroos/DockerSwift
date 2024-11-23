import NIOHTTP1
import Foundation

struct PruneContainersEndpoint: SimpleEndpoint {
	var body: Body?
	
	typealias Response = PruneContainersResponse
	typealias Body = NoBody
	var method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] { [] }

	init() {
		
	}
	
	var path: String {
		"containers/prune"
	}
	
	struct PruneContainersResponse: Codable {
		let ContainersDeleted: [String]?
		let SpaceReclaimed: UInt64
	}
}
