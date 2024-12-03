@testable import Paddock

extension RegistryLoginEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.string(#"{"IdentityToken":"","Status":"Login Succeeded"}"#)
		]
	}
}
