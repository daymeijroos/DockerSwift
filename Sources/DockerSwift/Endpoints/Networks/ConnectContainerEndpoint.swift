import NIOHTTP1
import Foundation

struct ConnectContainerEndpoint: SimpleEndpoint {
	typealias Body = ContainerConnect
	
	typealias Response = NoBody?
	var method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] { [] }
	var path: String {
		"networks/\(networkNameOrId)/connect"
	}
	var body: Body?
	
	private let networkNameOrId: String
	
	init(networkNameOrId: String, connectConfig: ContainerConnect) {
		self.networkNameOrId = networkNameOrId
		self.body = connectConfig
	}
}
