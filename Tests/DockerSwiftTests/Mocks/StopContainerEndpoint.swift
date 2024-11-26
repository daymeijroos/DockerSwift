import AsyncHTTPClient
import Foundation
import NIO
@testable import DockerSwift

extension StopContainerEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.rawData(ByteBuffer()),
		]
	}

	public func validate(request: HTTPClientRequest) throws {
		guard request.method == .POST else { throw DockerError.message("require post method") }
		guard
			let url = URL(string: request.url)
		else { throw DockerError.message("invalid url") }

		let components = url.pathComponents

		guard
			let containerIndex = components.firstIndex(of: "containers"),
			(components.startIndex..<components.endIndex).contains(containerIndex + 2),
			components[containerIndex + 2] == "stop"
		else { throw DockerError.message("invalid path for stop: \(url)") }
	}
}
