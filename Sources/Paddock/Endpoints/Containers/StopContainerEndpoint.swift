import NIO
import NIOHTTP1
import Foundation

struct StopContainerEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	
	typealias Response = NoBody?
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] {
		[
			stopTimeout.map { URLQueryItem(name: "t", value: $0.description) }
		]
			.compactMap(\.self)
	}

	var timeout: TimeAmount? { .seconds(stopTimeout.map { Int64($0) + 10 } ?? 20) }

	let containerId: String
	let stopTimeout: Int?

	init(containerId: String, stopTimeout: Int?) {
		self.containerId = containerId
		self.stopTimeout = stopTimeout
	}
	
	var path: String {
		"containers/\(containerId)/stop"
	}
}
