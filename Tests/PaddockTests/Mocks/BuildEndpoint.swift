@testable import Paddock

extension BuildEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.string(#"{"stream":"STEP 1/4: FROM alpine\n"}"#),
			.string(#"{"stream":"STEP 2/4: RUN echo \"Foo bar\"\n"}"#),
			.string(#"{"stream":"Foo bar\n"}"#),
			.string(#"{"stream":"--\u003e 28ccee7b5fee\n"}"#),
			.string(#"{"stream":"STEP 3/4: CMD /bin/sh\n"}"#),
			.string(#"{"stream":"--\u003e f2c1f27d0276\n"}"#),
			.string(#"{"stream":"STEP 4/4: LABEL \"test\"=\"value\"\n"}"#),
			.string(#"{"stream":"COMMIT docker.io/library/build:test\n"}"#),
			.string(#"{"stream":"--\u003e 55853d969ebc\n"}"#),
			.string(#"{"stream":"[Warning] one or more build args"#), // split in two
			.string(#" were not consumed: [TEST]\n"}"#),
			.string(#"{"stream":"Successfully tagged docker.io/library/build:test\n"}"#),
			.string(#"{"stream":"55853d969ebc2a89a361279bff91b59ca03fb22786659b6c84cad31a67629ef0\n"}"#),
			.string(#"{"aux":{"ID":"sha256:55853d969ebc2a89a361279bff91b59ca03fb22786659b6c84cad31a67629ef0"}}"#),
			.string(#"{"stream":"Successfully built 55853d969ebc\n"}"#),
			.string(#"{"stream":"Successfully tagged build:test\n"}"#),
		]
	}
}
