import NIOHTTP1
import Foundation

struct UpdateSwarmEndpoint: SimpleEndpoint {
	typealias Response = NoBody
	typealias Body = SwarmSpec
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] {
		[
			URLQueryItem(name: "version", value: version.description),
			URLQueryItem(name: "rotateWorkerToken", value: rotateWorkerToken.description),
			URLQueryItem(name: "rotateManagerToken", value: rotateManagerToken.description),
			URLQueryItem(name: "rotateManagerUnlockKey", value: rotateManagerUnlockKey.description),
		]
	}

	var body: Body?
	private let version: UInt64
	private let rotateWorkerToken: Bool
	private let rotateManagerToken: Bool
	private let rotateManagerUnlockKey: Bool

	init(spec: SwarmSpec, version: UInt64, rotateWorkerToken: Bool, rotateManagerToken: Bool, rotateManagerUnlockKey: Bool) {
		self.version = version
		self.rotateWorkerToken = rotateWorkerToken
		self.rotateManagerToken = rotateManagerToken
		self.rotateManagerUnlockKey = rotateManagerUnlockKey
		self.body = spec
	}
	
	var path: String {
		"swarm/update"
	}
	
	//struct UpdateSwarmResponse: Codable {}
}
