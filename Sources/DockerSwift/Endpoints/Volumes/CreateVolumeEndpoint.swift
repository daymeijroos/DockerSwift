import NIOHTTP1
import Foundation

struct CreateVolumeEndpoint: SimpleEndpoint {
	var body: Body?
	
	typealias Response = Volume
	typealias Body = VolumeSpec
	var method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] { [] }

	init(spec: VolumeSpec) {
		self.body = spec
	}
	
	var path: String {
		"volumes/create"
	}
}
