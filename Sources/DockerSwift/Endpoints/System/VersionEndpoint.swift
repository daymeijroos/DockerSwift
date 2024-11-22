import NIOHTTP1

struct NoBody: Codable {}

struct VersionEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = DockerVersion
	
	var method: HTTPMethod = .GET
	let path: String = "version"
}
