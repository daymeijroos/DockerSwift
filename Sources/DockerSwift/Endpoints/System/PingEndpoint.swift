import NIOHTTP1

struct PingEndpoint: SimpleEndpoint {
    typealias Body = NoBody
    typealias Response = String
    
    var method: HTTPMethod = .GET
    let path: String = "_ping"
}
