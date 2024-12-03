@testable import DockerSwift

extension ListVolumesEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.string(#"{"Volumes":[{"CreatedAt":"2024-12-03T13:55:27-06:00","Driver":"local","Labels":{},"Mountpoint":"/var/home/core/.local/share/containers/storage/volumes/TestVolumeStorage/_data","Name":"TestVolumeStorage","Options":{},"Scope":"local"}],"Warnings":[]}"#),
		]
	}
}
