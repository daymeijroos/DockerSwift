import Foundation
import NIOHTTP1

struct InspectImagesEndpoint: SimpleEndpoint {
    typealias Body = NoBody
    typealias Response = Image
    var method: HTTPMethod = .GET
    
    let nameOrId: String
    
    init(nameOrId: String) {
        self.nameOrId = nameOrId
    }
    
    var path: String {
        "images/\(nameOrId)/json"
    }
}
