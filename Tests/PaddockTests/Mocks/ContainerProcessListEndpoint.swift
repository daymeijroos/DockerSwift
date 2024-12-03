@testable import Paddock
import AsyncHTTPClient
import Foundation

extension ContainerProcessListEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.string(#"{"Processes":[["root           1       0 14 00:01 ?        00:00:00 nginx: master process nginx -g daemon off;"],["101           24       1  0 00:01 ?        00:00:00 nginx: worker process"],["101           25       1  0 00:01 ?        00:00:00 nginx: worker process"],["101           26       1  0 00:01 ?        00:00:00 nginx: worker process"],["101           27       1  0 00:01 ?        00:00:00 nginx: worker process"]],"Titles":["UID","PID","PPID","C","STIME","TTY","TIME","CMD"]}"#)
		]
	}

	public func validate(request: HTTPClientRequest) throws {
		let url = try validate(method: .GET, andGetURLFromRequest: request)

		guard
			url.pathComponents.last == "top"
		else { throw DockerError.message("Invalid path") }
	}
}
