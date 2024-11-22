import NIOHTTP1

struct SystemInformationEndpoint: SimpleEndpoint {
    typealias Body = NoBody
    typealias Response = SystemInformation
    
    var method: HTTPMethod = .GET
    let path: String = "info"
}
