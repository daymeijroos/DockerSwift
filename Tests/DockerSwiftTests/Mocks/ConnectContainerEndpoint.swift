import AsyncHTTPClient
@testable import DockerSwift

extension ConnectContainerEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {[.string("OK")]}

	public func validate(request: HTTPClientRequest) throws {
		let url = try validate(method: .POST, andGetURLFromRequest: request)

		guard
			let connectIndex = url.pathComponents.lastIndex(of: "connect"),
			connectIndex >= 2,
			url.pathComponents[connectIndex - 2] == "networks"
		else { throw DockerError.message("Invalid path") }
	}
}
