import NIOHTTP1
import Foundation

struct PruneVolumesEndpoint: SimpleEndpoint {
    var body: Body?
    
    typealias Response = PrunedVolumes
    typealias Body = NoBody
    var method: HTTPMethod = .POST
        
    init() {}
    
    var path: String {
        "volumes/prune"
    }
}

