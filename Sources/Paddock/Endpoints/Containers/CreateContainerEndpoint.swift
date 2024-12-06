import NIOHTTP1
import Foundation
import Logging

public struct CreateContainerEndpoint: SimpleEndpoint {
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] {
		[
			name.map { URLQueryItem(name: "name", value: $0) },
			platform.map { URLQueryItem(name: "platform", value: $0) }
		]
			.compactMap(\.self)
	}
	var path: String { "containers/create" }

	let body: ContainerConfig?
	let name: String?
	let platform: String?
	let logger: Logger

	init(name: String? = nil, platform: String? = nil, config: ContainerConfig, logger: Logger) {
		self.name = name
		self.body = config
		self.platform = platform
		self.logger = logger
	}

	public struct Response: Codable {
		public let id: String
		public let warnings: [String]

		enum CodingKeys: String, CodingKey {
			case id = "Id"
			case warnings = "Warnings"
		}
	}
}
