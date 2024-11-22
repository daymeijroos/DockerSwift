import AsyncHTTPClient
import Foundation
import NIOHTTP1

extension HTTPClientRequest {
	public init(
		daemonURL: URL,
		urlPath: String,
		method: HTTPMethod,
		body: HTTPClientRequest.Body? = nil,
		headers: HTTPHeaders
	) throws {
		guard
			let newURL = URL(string: daemonURL.absoluteString.trimmingCharacters(in: CharacterSet(charactersIn: "/")) + urlPath)
		else { throw HTTPClientError.invalidURL }

		self.init(url: newURL.absoluteString)
		self.method = method
		self.body = body
		self.headers = headers
	}
}
