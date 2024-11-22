import Foundation
import NIOHTTP1

struct ListConfigsEndpoint: SimpleEndpoint {
    typealias Body = NoBody
    typealias Response = [Config]
    var method: HTTPMethod = .GET
    
    init() {
    }
    
    var path: String {
        "configs"
    }
}
