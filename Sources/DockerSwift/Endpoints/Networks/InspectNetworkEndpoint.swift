import Foundation
import NIOHTTP1

struct InspectNetworkEndpoint: SimpleEndpoint {
    typealias Body = NoBody
    typealias Response = Network
    var method: HTTPMethod = .GET
    
    private let nameOrId: String
    
    init(nameOrId: String) {
        self.nameOrId = nameOrId
    }
    
    var path: String {
        "networks/\(nameOrId)"
    }
}
