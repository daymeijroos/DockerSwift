import NIOHTTP1
import Foundation

struct RegistryLoginEndpoint: SimpleEndpoint {
	var body: Body?
	
	typealias Response = RegistryLoginResponse
	typealias Body = RegistryAuth
	var method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] { [] }

	init(credentials: RegistryAuth) {
		self.body = credentials
	}
	
	var path: String {
		"auth"
	}
	
	struct RegistryLoginResponse: Codable {
		let Status: String
		let IdentityToken: String?
	}
}
