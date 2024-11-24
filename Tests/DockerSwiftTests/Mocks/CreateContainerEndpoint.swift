@testable import DockerSwift

extension CreateContainerEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		switch (body.image, body.command) {
		case ("hello-world:latest", nil), ("nginx:latest", nil):
			return [
				.string(#"{"Id":"ce25040926ba103e72dd4070db9a07c4510291a3a3475b0cb175dd06dddfbc93","Warnings":[]}"#)
			]
		default:
			logger.debug("Unexpected mock request for \(Self.self) - \(body.image) \(body.command as Any)")
			return []
		}

	}
}
