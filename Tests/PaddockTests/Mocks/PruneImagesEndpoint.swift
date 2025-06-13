@testable import Paddock

extension PruneImagesEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.string(#"{"ImagesDeleted":[{"Deleted":"7a3f95c078122f959979fac556ae6f43746c9f32e5a66526bb503ed1d4adbd07"}],"SpaceReclaimed":200984620}"#)
		]
	}
}
