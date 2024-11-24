import NIOHTTP1
import Foundation

struct PruneNetworksEndpoint: SimpleEndpoint {
	var body: Body?

	typealias Response = PrunedNetworks
	typealias Body = NoBody
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] { [] }

	var path: String {
		"networks/prune"
	}

	struct PrunedNetworks: Codable {
		let NetworksDeleted: [String]
	}
}

