import Foundation

final class GetEventsEndpoint: JSONStreamingEndpoint<DockerEvent> {

	override var path: String {
		"events?since=\(since != nil ? since!.description : "")&until=\(until != nil ? until!.description : "")"
	}
	
	private let since: Int64?
	private let until: Int64?
	
	init(since: Date?, until: Date?) {
		self.since = since != nil ? Int64(since!.timeIntervalSince1970) : nil
		self.until = until != nil ? Int64(until!.timeIntervalSince1970) : nil
		super.init(path: "")
	}
}

extension GetEventsEndpoint: MockedResponseEndpoint {
	var responseData: [MockedResponseData] {
		[
			.string("""
				{"status":"create","id":"ce25040926ba103e72dd4070db9a07c4510291a3a3475b0cb175dd06dddfbc93","from":"docker.io/library/hello-world:latest","Type":"container","Action":"create","Actor":{"ID":"ce25040926ba103e72dd4070db9a07c4510291a3a3475b0cb175dd06dddfbc93","Attributes":{"image":"docker.io/library/hello-world:latest","name":"81A5DB11-78E9-4B21-9943-23FB75818224","podId":""}},"scope":"local","time":1732265952,"timeNano":1732265952421651736}
				""")
		]
	}
}
