import AsyncHTTPClient
@testable import DockerSwift

extension CreateVolumeEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		guard let body else {
			logger.error("Create volume request body not found.")
			return []
		}
		switch body.name {
		case "TestVolumeStorage":
			return [
				.string(#"{"CreatedAt":"2024-12-03T13:33:50-06:00","Driver":"local","Labels":{"myLabel":"value"},"Mountpoint":"/var/home/core/.local/share/containers/storage/volumes/6E6ECDC1-A20B-46B5-8079-E8CB754DEAE7/_data","Name":"TestVolumeStorage","Options":null,"Scope":"local"}"#)
			]
		default:
			logger.error("⚠️ Requested mock volume creation not found: \(body.name as Any).")
			return []
		}
	}

	public func validate(request: HTTPClientRequest) throws {
		try validate(method: .POST, andGetURLFromRequest: request)
	}
}
