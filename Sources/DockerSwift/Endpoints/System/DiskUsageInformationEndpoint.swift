import NIOHTTP1

public struct DiskUsageInformationEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = DataUsageInformation
	
	var method: HTTPMethod = .GET
	let path: String = "system/df"
}
