@testable import DockerSwift

extension PruneContainersEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.string(#"{"ContainersDeleted":["ce25040926ba103e72dd4070db9a07c4510291a3a3475b0cb175dd06dddfbc93"],"SpaceReclaimed":25884}"#),
		]
	}
}
