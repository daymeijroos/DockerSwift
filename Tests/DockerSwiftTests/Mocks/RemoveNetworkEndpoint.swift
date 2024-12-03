import AsyncHTTPClient
@testable import DockerSwift
import NIO

extension RemoveNetworkEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {[.rawData(ByteBuffer())]}

	public func validate(request: HTTPClientRequest) throws {
		let url = try validate(method: .DELETE, andGetURLFromRequest: request)

		guard
			let index = url.pathComponents.lastIndex(of: "networks"),
			index < url.pathComponents.endIndex - 1
		else { throw DockerError.message("Invalid path") }
	}
}
