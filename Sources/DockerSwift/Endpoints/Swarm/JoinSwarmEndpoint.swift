import NIOHTTP1
import Foundation

public struct JoinSwarmEndpoint: SimpleEndpoint {
    var body: Body?
    
    typealias Body = SwarmJoin
    typealias Response = NoBody
    var method: HTTPMethod = .POST
    
    var path: String {
        "swarm/join"
    }
    
    init(config: SwarmJoin) {
        self.body = config
    }
}
