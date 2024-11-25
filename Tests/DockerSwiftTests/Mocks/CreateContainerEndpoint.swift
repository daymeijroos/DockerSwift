@testable import DockerSwift

extension CreateContainerEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		guard let body else {
			logger.debug("Unexpected lack of container configuration for \(Self.self)")
			return []
		}
		switch (body.image, body.command) {
		case
			("nginx:latest", nil),
			("hello-world:latest", ["/custom/command", "--option"]):
			return [
				.string(#"{"Id":"ce25040926ba103e72dd4070db9a07c4510291a3a3475b0cb175dd06dddfbc93","Warnings":[]}"#)
			]
		case ("hello-world:latest", _):
			return [
				.string(#"{"Id":"7eb61d5ac2202df115c7ef2875732b800d7e20c1e7e53e7eb470afa2b98bfd72","Warnings":[]}"#)
			]

		default:
			logger.debug("Unexpected mock request for \(Self.self) - \(body.image) \(body.command as Any)")
			return []
		}

	}
}
