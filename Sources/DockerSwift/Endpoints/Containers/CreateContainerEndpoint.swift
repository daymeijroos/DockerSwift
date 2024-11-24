import NIOHTTP1
import Foundation

struct CreateContainerEndpoint: SimpleEndpoint {
	typealias Body = ContainerConfig
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] {
		[
			name.map { URLQueryItem(name: "name", value: $0) }
		]
			.compactMap(\.self)
	}
	var path: String { "containers/create" }

	var body: ContainerConfig?
	private let name: String?

	init(name: String? = nil, spec: ContainerConfig) {
		self.name = name
		self.body = spec
	}

	struct Response: Codable {
		let Id: String
		let Warnings: [String]
	}
}
