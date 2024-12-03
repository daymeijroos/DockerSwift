import NIOHTTP1
import Foundation

struct PauseUnpauseContainerEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	
	typealias Response = NoBody?
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] { [] }

	private let nameOrId: String
	// if `false`, will pause
	private let unpause: Bool
	
	init(nameOrId: String, unpause: Bool) {
		self.nameOrId = nameOrId
		self.unpause = unpause
	}
	
	var path: String {
		"containers/\(nameOrId)/\(unpause ? "unpause" : "pause")"
	}
}
