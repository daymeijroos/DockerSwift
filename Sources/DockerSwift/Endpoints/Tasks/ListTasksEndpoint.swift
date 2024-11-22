import Foundation
import NIOHTTP1

struct ListTasksEndpoint: SimpleEndpoint {
    typealias Body = NoBody
    typealias Response = [SwarmTask]
    var method: HTTPMethod = .GET
    
    init() {
    }
    
    var path: String {
        "tasks"
    }
}
