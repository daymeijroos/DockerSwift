import NIOHTTP1
import Foundation

struct SimpleCreateContainerEndpoint: SimpleEndpoint {
	var body: CreateContainerBody?
	
	typealias Response = CreateContainerResponse
	typealias Body = CreateContainerBody
	var method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] { [] }

	private let imageName: String
	private let commands: [String]?
	
	init(imageName: String, commands: [String]? = nil) {
		self.imageName = imageName
		self.commands = commands
		self.body = .init(Image: imageName, Cmd: commands)
	}
	
	var path: String {
		"containers/create"
	}

	struct CreateContainerBody: Codable {
		let Image: String
		let Cmd: [String]?
	}
	
	struct CreateContainerResponse: Codable {
		let Id: String
	}
}

struct CreateContainerEndpoint: SimpleEndpoint {
	typealias Response = CreateContainerResponse
	typealias Body = ContainerSpec
	var method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] {
		[
			name.map { URLQueryItem(name: "name", value: $0) }
		]
			.compactMap(\.self)
	}

	var body: ContainerSpec?
	private let name: String?
	
	init(name: String? = nil, spec: ContainerSpec) {
		self.name = name
		self.body = spec
	}
	
	var path: String {
		"containers/create"
	}

	struct CreateContainerResponse: Codable {
		let Id: String
		let Warnings: [String]
	}
}
