import NIOHTTP1
import Foundation

struct TagImageEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = NoBody
	let method: HTTPMethod = .POST
	
	private let nameOrId: String
	private let repoName: String
	private let tag: String
	var queryArugments: [URLQueryItem] {
		[
			URLQueryItem(name: "repo", value: repoName),
			URLQueryItem(name: "tag", value: tag)
		]
	}

	var path: String {
		"images/\(nameOrId)/tag"
	}
	
	init(nameOrId: String, repoName: String, tag: String) {
		self.nameOrId = nameOrId
		self.repoName = repoName
		self.tag = tag
	}
}
