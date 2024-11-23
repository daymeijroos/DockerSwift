import NIOHTTP1
import Foundation

struct SystemInformationEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = SystemInformation
	var queryArugments: [URLQueryItem] { [] }

	var method: HTTPMethod = .GET
	let path: String = "info"
}
