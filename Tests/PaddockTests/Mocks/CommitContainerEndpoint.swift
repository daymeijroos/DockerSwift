@testable import Paddock

extension CommitContainerEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.string(#"{"Id":"f3a782e6ae07e63291cb43cf524c6ac2df85fd2f168a8c9f7ed784900094295f"}"#)
		]
	}
}
