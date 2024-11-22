import NIOHTTP1

struct ConfigurePluginEndpoint: SimpleEndpoint {
	typealias Response = NoBody
	typealias Body = [String]
	var method: HTTPMethod = .POST
	
	var path: String {
		"plugins/\(name)/set"
	}
	var headers: HTTPHeaders? = nil
	var body: Body?
	
	private let name: String
	
	init(name: String, config: [String]) {
		self.body = config
		self.name = name
		
	}
}
