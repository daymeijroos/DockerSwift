import AsyncHTTPClient
import Foundation
import NIOHTTP1

extension HTTPClientRequest {
	public init(
		socketURL: URL,
		urlPath: String,
		queryItems: [URLQueryItem],
		method: HTTPMethod,
		body: HTTPClientRequest.Body? = nil,
		headers: HTTPHeaders
	) {
		var newURL = socketURL
			.appending(path: urlPath.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
		if queryItems.isEmpty == false {
			newURL
				.append(queryItems: queryItems)
		}

		self.init(url: newURL.absoluteString)
		self.method = method
		self.body = body
		self.headers = headers
	}
}
