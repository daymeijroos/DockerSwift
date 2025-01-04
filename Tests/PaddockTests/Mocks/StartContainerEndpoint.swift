import AsyncHTTPClient
import Foundation
@testable import Paddock
import NIO

extension StartContainerEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.rawData(ByteBuffer())
		]
	}

	public func validate(request: HTTPClientRequest) throws {
		guard request.method == .POST else { throw DockerGeneralError.message("require post method") }
		guard
			let url = URL(string: request.url)
		else { throw DockerGeneralError.message("invalid url") }

		let components = url.pathComponents

		guard
			let containerIndex = components.firstIndex(of: "containers"),
			(components.startIndex..<components.endIndex).contains(containerIndex + 2),
			components[containerIndex + 2] == "start"
		else { throw DockerGeneralError.message("invalid path for start: \(url)") }
	}
}
