import Foundation
import NIOHTTP1

struct ListServicesEndpoint: SimpleEndpoint {
    typealias Body = NoBody
    typealias Response = [Service]
    var method: HTTPMethod = .GET
    
    init() {
    }
    
    var path: String {
        "services?insertDefaults=true"
    }
}
