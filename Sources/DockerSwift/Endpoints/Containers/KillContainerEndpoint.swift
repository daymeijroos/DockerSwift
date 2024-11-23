import NIOHTTP1
import Foundation

struct KillContainerEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	
	typealias Response = NoBody?
	var method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] {
		[URLQueryItem(name: "signal", value: signal.rawValue)]
	}

	private let containerId: String
	private let signal: UnixSignal
	
	init(containerId: String, signal: UnixSignal) {
		self.containerId = containerId
		self.signal = signal
	}
	
	var path: String {
		"containers/\(containerId)/kill"
	}
}
