import NIOHTTP1
import Foundation

struct StopContainerEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	
	typealias Response = NoBody?
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] {
		[
			timeout.map { URLQueryItem(name: "t", value: $0.description) }
		]
			.compactMap(\.self)
	}

	private let containerId: String
	private let timeout: UInt?
	
	init(containerId: String, timeout: UInt?) {
		self.containerId = containerId
		self.timeout = timeout
	}
	
	var path: String {
		"containers/\(containerId)/stop"
	}
}
