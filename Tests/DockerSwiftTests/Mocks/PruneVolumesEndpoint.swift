@testable import DockerSwift

extension PruneVolumesEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.string(#"{"VolumesDeleted":["TestVolumeStorage"],"SpaceReclaimed":4096}"#),
		]
	}
}
