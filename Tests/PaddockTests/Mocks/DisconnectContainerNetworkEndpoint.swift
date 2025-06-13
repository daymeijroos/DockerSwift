import AsyncHTTPClient
@testable import Paddock

extension DisconnectContainerNetworkEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {[.string("OK")]}

	public func validate(request: HTTPClientRequest) throws {
		let url = try validate(method: .POST, andGetURLFromRequest: request)

		guard
			let disconnectIndex = url.pathComponents.lastIndex(of: "disconnect"),
			disconnectIndex >= 2,
			url.pathComponents[disconnectIndex - 2] == "networks"
		else { throw DockerGeneralError.message("Invalid path") }
	}
}
