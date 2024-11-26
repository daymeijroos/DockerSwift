import AsyncHTTPClient
import Foundation
@testable import DockerSwift
import NIO

extension StartContainerEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.rawData(ByteBuffer())
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
			components[containerIndex + 2] == "start"
		else { throw DockerError.message("invalid path for start: \(url)") }
	}
}
