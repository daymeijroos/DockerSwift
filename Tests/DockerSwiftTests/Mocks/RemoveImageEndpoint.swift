@testable import DockerSwift

extension RemoveImageEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.string(#"[{"Deleted":"7a3f95c078122f959979fac556ae6f43746c9f32e5a66526bb503ed1d4adbd07"},{"Untagged":"docker.io/library/nginx:latest"}]"#)
		]
	}
}
