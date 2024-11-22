import NIOHTTP1

struct CreateNetworkEndpoint: SimpleEndpoint {
	var body: Body?
	
	typealias Response = CreateNetworkResponse
	typealias Body = NetworkSpec
	var method: HTTPMethod = .POST
	
	init(spec: NetworkSpec) {
		self.body = spec
	}
	
	var path: String {
		"networks/create"
	}
	
	struct CreateNetworkResponse: Codable {
		let Id: String
		let Warning: String?
	}
}
