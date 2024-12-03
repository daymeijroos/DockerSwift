@testable import DockerSwift

extension CreateNetworkEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		guard let body else { return [] }
		switch body.name {
		case "11E46E6F-BF6B-474B-A6E5-E08E1E48D454":
			return [
				.string(#"{"Id":"7e77192f93582449e5806dc32639808ae078e0d5f38cc4636f1d7b9057e8c6e1", "Warning":""}"#)
			]
		default:
			logger.error("Requested mock network creation not found: \(body.name).")
			return []
		}
	}
}
