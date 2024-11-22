import AsyncHTTPClient
import Foundation
import NIOHTTP1

extension HTTPClient.Request {
	public init(daemonURL: URL, urlPath: String, method: HTTPMethod, body: HTTPClient.Body? = nil, headers: HTTPHeaders) throws {
		guard
			let url = URL(string: daemonURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/")) + urlPath)
		else { throw HTTPClientError.invalidURL }
		try self.init(url: url, method: method, headers: headers, body: body)
	}
}

extension HTTPClientRequest {
	public init(
		daemonURL: URL,
		urlPath: String,
		method: HTTPMethod,
		body: HTTPClientRequest.Body? = nil,
		headers: HTTPHeaders
	) {
		let url = daemonURL.appending(path: urlPath)
		self.init(url: url.absoluteString)
		self.method = method
		self.body = body
		self.headers = headers
	}
}
