import NIOHTTP1
import Foundation

public struct DiskUsageInformationEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = DataUsageInformation
	
	var method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] { [] }
	let path: String = "system/df"
}
