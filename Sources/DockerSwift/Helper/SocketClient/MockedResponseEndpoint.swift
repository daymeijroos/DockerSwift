import NIO
import Foundation
import NIOHTTP1

protocol MockedResponseEndpoint: Endpoint {
	var responseData: [MockedResponseData] { get }
	var responseHeader: HTTPHeaders { get }
	var responseSuccessStatus: HTTPResponseStatus { get }
}

extension MockedResponseEndpoint {
	func mockedResponse() async throws -> ByteBuffer {
		guard
			let first = responseData.first
		else { throw DockerError.message("Error retrieving mock data") }

		try await Task.sleep(for: .milliseconds(5))
		return first.data
	}
}

enum MockedResponseData {
	case rawData(ByteBuffer)
	case string(String)
	case base64EncodedString(String)

	var data: ByteBuffer {
		switch self {
		case .rawData(let data):
			data
		case .string(let string):
			ByteBuffer(string: string)
		case .base64EncodedString(let b64):
			ByteBuffer(data: Data(base64Encoded: b64) ?? Data())
		}
	}
}

