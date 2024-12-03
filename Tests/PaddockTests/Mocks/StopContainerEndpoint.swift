import AsyncHTTPClient
import Foundation
import NIO
@testable import Paddock

extension StopContainerEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.rawData(ByteBuffer()),
		]
	}

	public func validate(request: HTTPClientRequest) throws {
		let url = try validate(method: .POST, andGetURLFromRequest: request)

		let components = url.pathComponents

		guard
			let containerIndex = components.firstIndex(of: "containers"),
			(components.startIndex..<components.endIndex).contains(containerIndex + 2),
			components[containerIndex + 2] == "stop"
		else { throw DockerError.message("invalid path for stop: \(url)") }
	}
}
