import NIOHTTP1
import Foundation
import Logging

public struct CreateContainerEndpoint: SimpleEndpoint {
	typealias Body = ContainerConfig
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] {
		[
			name.map { URLQueryItem(name: "name", value: $0) }
		]
			.compactMap(\.self)
	}
	var path: String { "containers/create" }

	var body: ContainerConfig
	private let name: String?
	let logger: Logger

	init(name: String? = nil, spec: ContainerConfig, logger: Logger) {
		self.name = name
		self.body = spec
		self.logger = logger
	}

	public struct Response: Codable {
		let id: String
		let warnings: [String]

		enum CodingKeys: String, CodingKey {
			case id = "Id"
			case warnings = "Warnings"
		}
	}
}
