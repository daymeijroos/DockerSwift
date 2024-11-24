import NIOHTTP1
import Foundation

struct PruneVolumesEndpoint: SimpleEndpoint {
	var body: Body?
	var queryArugments: [URLQueryItem] { [] }

	typealias Response = PrunedVolumes
	typealias Body = NoBody
	let method: HTTPMethod = .POST
		
	init() {}
	
	var path: String {
		"volumes/prune"
	}
}

