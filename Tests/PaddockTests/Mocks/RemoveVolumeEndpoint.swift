import AsyncHTTPClient
@testable import Paddock
import NIO

extension RemoveVolumeEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.rawData(ByteBuffer())
		]
	}

	public func validate(request: HTTPClientRequest) throws {
		let url = try validate(method: .DELETE, andGetURLFromRequest: request)

		guard
			let volIndex = url.pathComponents.firstIndex(of: "volumes"),
			volIndex < url.pathComponents.count - 1
		else { throw DockerGeneralError.message("Invalid path") }
	}
}
