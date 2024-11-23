@testable import DockerSwift

extension RegistryLoginEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.string(#"{"IdentityToken":"","Status":"Login Succeeded"}"#)
		]
	}
}
