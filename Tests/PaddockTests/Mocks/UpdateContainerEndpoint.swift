@testable import Paddock
import AsyncHTTPClient

extension UpdateContainerEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		switch nameOrId {
		case "fail":
			[
				.string(#"{"Warnings": ["Too much flux in your capacitor", "You got peanut butter on my chocolate", "You got chocolate on my peanut butter"]}"#)
			]
		default:
			[
				.string(#"{"Warnings":null}"#)
			]
		}
	}

	public func validate(request: HTTPClientRequest) throws {
		try validate(method: .POST, andGetURLFromRequest: request)
	}
}
