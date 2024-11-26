import Foundation
import NIOHTTP1

public struct ContainerProcessListEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	let method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] {
		[URLQueryItem(name: "ps_args", value: psArgs)]
	}

	let nameOrId: String
	let psArgs: String
	
	var path: String {
		"containers/\(nameOrId)/top"
	}
	
	init(nameOrId: String, psArgs: String) {
		self.nameOrId = nameOrId
		self.psArgs = psArgs
	}

	public struct Response: Codable {
		/// The `ps` column titles
		public let titles: [String]

		/// Processes running in the container, where each item is an array of values corresponding to the titles.
		public let processes: [[String]]

		enum CodingKeys: String, CodingKey {
			case titles = "Titles"
			case processes = "Processes"
		}
	}
}
