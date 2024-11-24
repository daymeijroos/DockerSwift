import NIOHTTP1
import Foundation
import Logging

struct PullImageEndpoint: PipelineEndpoint {
	typealias Body = NoBody
	typealias Response = PullImageResponse
	let method: HTTPMethod = .POST

	let imageName: String
	let token: RegistryAuth.Token?
	var queryArugments: [URLQueryItem] {
		[URLQueryItem(name: "fromImage", value: imageName)]
	}

	let logger: Logger

	var path: String {
		"images/create"
	}

	var headers: HTTPHeaders? = nil

	init(imageName: String, token: RegistryAuth.Token?, logger: Logger) {
		self.imageName = imageName
		self.token = token
		if let token {
			self.headers = .init([("X-Registry-Auth", token.rawValue)])
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

