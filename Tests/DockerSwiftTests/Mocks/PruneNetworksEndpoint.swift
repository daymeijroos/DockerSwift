@testable import DockerSwift
import AsyncHTTPClient

extension PruneNetworksEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.string(#"{"NetworksDeleted":["11E46E6F-BF6B-474B-A6E5-E08E1E48D454","776F2F45-D1BE-49B8-B0B0-1ECD6BA57D19"]}"#)
		]
	}

	public func validate(request: HTTPClientRequest) throws {
		try validate(method: .POST, andGetURLFromRequest: request)
	}
}
