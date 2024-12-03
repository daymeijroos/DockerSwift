@testable import Paddock
import Foundation
import NIO
import AsyncHTTPClient

extension PauseUnpauseContainerEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.rawData(ByteBuffer())
		]
	}

	public func validate(request: HTTPClientRequest) throws {
		let url = try validate(method: .POST, andGetURLFromRequest: request)

		let components = url.pathComponents

		guard
			let containerIndex = components.firstIndex(of: "containers"),
			(components.startIndex..<components.endIndex).contains(containerIndex + 2),
			case let command = components[containerIndex + 2],
			["pause", "unpause"].contains(command)
		else { throw DockerError.message("invalid path for pause/unpause: \(url)") }
	}
}
