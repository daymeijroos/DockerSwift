@testable import Paddock

extension PullImageEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		switch imageName {
		case "hello-world:latest":
			return [
				.string(#"{"status":"Already exists","progressDetail":{},"id":"478afc919002"}"#),
				.string(#"{"status":"Pulling fs layer","progressDetail":{},"id":"ee301c921b8a"}"#),
				.string(#"{"status":"Download complete","progressDetail":{},"id":"ee301c921b8a"}"#),
				.string(#"{"status":"Download complete","progressDetail":{},"id":"ee301c921b8a"}"#),
			]
		case "nginx:latest":
			return [
				.string(#"{"status":"Download complete","progressDetail":{},"id":"81815610209d"}"#),
				.string(#"{"status":"Pulling fs layer","progressDetail":{},"id":"6d29a096dd42"}"#),
				.string(#"{"status":"Pulling fs layer","progressDetail":{},"id":"08d4c0cc9f6f"}"#),
				.string(#"{"status":"Download complete","progressDetail":{},"id":"08d4c0cc9f6f"}"#),
				.string(#"{"status":"Pulling fs layer","progressDetail":{},"id":"1d6368a7ae7d"}"#),
				.string(#"{"status":"Pulling fs layer","progressDetail":{},"id":"082d73fa4431"}"#),
				.string(#"{"status":"Download complete","progressDetail":{},"id":"082d73fa4431"}"#),
				.string(#"{"status":"Pulling fs layer","progressDetail":{},"id":"4ffee2b99561"}"#),
				.string(#"{"status":"Pulling fs layer","progressDetail":{},"id":"b2c20fd96d44"}"#),
				.string(#"{"status":"Download complete","progressDetail":{},"id":"4ffee2b99561"}"#),
				.string(#"{"status":"Download complete","progressDetail":{},"id":"b2c20fd96d44"}"#),
				.string(#"{"status":"Downloading","progressDetail":{"current":39901447,"total":40417565},"progress":"[=================================================\u003e ]   39.9MB/40.42MB","id":"1d6368a7ae7d"}"#),
				.string(#"{"status":"Download complete","progressDetail":{},"id":"1d6368a7ae7d"}"#),
				.string(#"{"status":"Download complete","progressDetail":{},"id":"6d29a096dd42"}"#),
				.string(#"{"status":"Pulling fs layer","progressDetail":{},"id":"7a3f95c07812"}"#),
				.string(#"{"status":"Download complete","progressDetail":{},"id":"7a3f95c07812"}"#),
				.string(#"{"status":"Download complete","progressDetail":{},"id":"7a3f95c07812"}"#),
			]
		default:
			logger.error("⚠️ Requested image not found: \(imageName).")
			return []
		}
	}
}
