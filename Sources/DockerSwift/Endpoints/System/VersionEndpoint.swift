import NIOHTTP1
import Foundation

struct NoBody: Codable {}

struct VersionEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = DockerVersion
	
	var method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] { [] }
	let path: String = "version"
}
