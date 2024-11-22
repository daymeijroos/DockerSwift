import NIOHTTP1
import Foundation
import Logging

struct PullImageEndpoint: PipelineEndpoint {
    typealias Body = NoBody
    typealias Response = PullImageResponse
    var method: HTTPMethod = .POST
    
    let imageName: String
    let credentials: RegistryAuth?

    let logger: Logger

    var path: String {
        "images/create?fromImage=\(imageName)"
    }
    
    var headers: HTTPHeaders? = nil
    
    init(imageName: String, credentials: RegistryAuth?, logger: Logger) {
        self.imageName = imageName
        self.credentials = credentials
        if let credentials = credentials, let token = credentials.token {
            self.headers = .init([("X-Registry-Auth", token)])
        }
        self.logger = logger
    }
    
    struct PullImageResponse: Codable {
        let digest: String
    }
    
    struct Status: Codable {
        let status: String
        let id: String?
    }
    
    func map(data: String) throws -> PullImageResponse {
        if let message = try? MessageResponse.decode(from: data) {
            throw DockerError.message(message.message)
        }
        let parts = data.components(separatedBy: .newlines)
            .filter({ $0.count > 0 })
            .compactMap({ try? Status.decode(from: $0) })

        if let digestPart = parts.last(where: { $0.status.hasPrefix("Digest:")}) {
            // docker flavor
            let digest = digestPart.status.replacingOccurrences(of: "Digest: ", with: "")
            return .init(digest: digest)
        } else if let idPart = parts.last(where: { $0.id != nil }), let id = idPart.id {
            // podman flavor
            return .init(digest: id)
        } else {
            throw DockerError.unknownResponse(data)
        }
    }
}

extension PullImageEndpoint: MockedResponseEndpoint {
    var responseData: [MockedResponseData] {
        switch imageName {
        case "hello-world:latest":
            return [
                .string(#"{"status":"Already exists","progressDetail":{},"id":"478afc919002"}"#),
                .string(#"{"status":"Pulling fs layer","progressDetail":{},"id":"ee301c921b8a"}"#),
                .string(#"{"status":"Download complete","progressDetail":{},"id":"ee301c921b8a"}"#),
                .string(#"{"status":"Download complete","progressDetail":{},"id":"ee301c921b8a"}"#),
            ]
        default:
            logger.error("Requested image not found: \(imageName).")
            return []
        }
    }
    

}
