@testable import DockerSwift

extension PushImageEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.string(#"{"status":"The push refers to repository [registry.gitlab.com/johnsmith/tests:29455605-C9F2-4C13-9E79-E8E97A96695C]"}"#),
			.string(#"{"status":"29455605-C9F2-4C13-9E79-E8E97A96695C: digest: sha256:7b2e19e8bd1851ef851e3fc6a9c80311046763a3ec134e7c47696bd0451388e8 size: 1025"}"#),
		]
	}
}

