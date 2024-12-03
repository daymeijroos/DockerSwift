import NIO
import NIOHTTP1
import Foundation
import Logging

public struct PullImageEndpoint: PipelineEndpoint {
	typealias Body = NoBody
	let method: HTTPMethod = .POST

	private static let decoder = JSONDecoder()

	let imageName: String
	let token: RegistryAuth.Token?
	var queryArugments: [URLQueryItem] {
		[URLQueryItem(name: "fromImage", value: imageName)]
	}
	var timeout: TimeAmount?

	let logger: Logger

	var body: NoBody?

	var path: String {
		"images/create"
	}

	var headers: HTTPHeaders? = nil

	init(imageName: String, token: RegistryAuth.Token?, timeout: TimeAmount? = nil, logger: Logger) {
		self.imageName = imageName
		self.token = token
		if let token {
			self.headers = .init([("X-Registry-Auth", token.rawValue)])
		}
		self.timeout = timeout ?? .minutes(2)
		self.logger = logger
	}

	public struct FinalResponse: Codable {
		/// digest of the pulled image
		public let digest: String
	}

	public struct Response: Codable {
		let status: String
		let id: String?
	}

	func finalize(_ parts: [Response]) async throws -> FinalResponse {
		if let digestPart = parts.last(where: { $0.status.hasPrefix("Digest:")}) {
			// docker flavor
			let digest = digestPart.status.replacingOccurrences(of: "Digest: ", with: "")
			return .init(digest: digest)
		} else if let idPart = parts.last(where: { $0.id != nil }), let id = idPart.id {
			// podman flavor
			return .init(digest: id)
		} else {
			throw DockerError.unknownResponse("\(parts)")
		}
	}
}

extension PullImageEndpoint: StreamingEndpoint {
	func mapStreamChunk(_ buffer: ByteBuffer, remainingBytes: inout ByteBuffer) async throws(StreamChunkError) -> [Response] {
		try await mapDecodableStreamChunk(buffer, decoder: Self.decoder, remainingBytes: &remainingBytes)
	}
}
