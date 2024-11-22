import NIOHTTP1

struct StopContainerEndpoint: SimpleEndpoint {
    typealias Body = NoBody
    
    typealias Response = NoBody?
    var method: HTTPMethod = .POST
    
    private let containerId: String
    private let timeout: UInt?
    
    init(containerId: String, timeout: UInt?) {
        self.containerId = containerId
        self.timeout = timeout
    }
    
    var path: String {
        "containers/\(containerId)/stop\(timeout != nil ? "?t=\(timeout!)" : "")"
    }
}
