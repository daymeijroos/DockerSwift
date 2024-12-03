import Foundation
import NIO
import AsyncHTTPClient
import Logging

extension HTTPClientResponse {
	/// This function checks the current response fot the status code. If it is not in the range of `200...299` it throws an error
	/// - Throws: Throws a `DockerError.errorCode` error. If the response is a `MessageResponse` it uses the `message` content for the message, otherwise the body will be used.
	func checkStatusCode() throws {
		guard 200...299 ~= self.status.code else {
			throw DockerError.errorCode(Int(self.status.code), "\(status.reasonPhrase)")
		}
	}
}
