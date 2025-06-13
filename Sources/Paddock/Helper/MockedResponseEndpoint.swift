import NIO
import Foundation
import NIOHTTP1
import AsyncHTTPClient

protocol MockedResponseEndpoint: Endpoint {
	var responseData: [MockedResponseData] { get }

	func mockedResponse(_ request: HTTPClientRequest) async throws -> ByteBuffer
	func mockedStreamingResponse(_ request: HTTPClientRequest) async throws -> AsyncThrowingStream<ByteBuffer, Error>

	func validate(request: HTTPClientRequest) throws
}

protocol BidirectionalMockEndpoint: MockedResponseEndpoint {
	var reactiveData: [ByteBuffer: [MockedResponseData]] { get }

	var streamContinuation: AsyncThrowingStream<ByteBuffer, Error>.Continuation? { get set }

	func send(_ buffer: ByteBuffer) async throws
	mutating func mockedStreamingResponse(_ request: HTTPClientRequest) async throws -> AsyncThrowingStream<ByteBuffer, Error>
}

extension MockedResponseEndpoint {
	static var podmanHeaders: HTTPHeaders {
		[
			"Api-Version": "1.41",
			"Server": "Libpod/5.2.3 (linux)",
			"Libpod-Api-Version": "5.2.3",
		]
	}

	static var dockerHeaders: HTTPHeaders {
		[
			"Api-Version": "1.47",
			"Server": "Docker/27.3.1 (linux)",
			"Docker-Experimental": "false",
			"Ostype": "linux",
		]
	}

	func superMockedResponse(_ request: HTTPClientRequest, sleepDelay: Duration) async throws -> ByteBuffer {
		guard
			let first = responseData.first
		else { throw DockerGeneralError.message("Error retrieving mock data") }

		try await Task.sleep(for: sleepDelay)
		return first.data
	}

	func mockedResponse(_ request: HTTPClientRequest) async throws -> ByteBuffer {
		try await superMockedResponse(request, sleepDelay: .milliseconds(5))
	}

	func superMockedStreamingResponse(_ request: HTTPClientRequest, intermittentSleepDuration: Duration) async throws -> AsyncThrowingStream<ByteBuffer, Error> {
		guard responseData.isEmpty == false else { throw DockerGeneralError.message("No mocked data available") }

		let (stream, continuation) = AsyncThrowingStream<ByteBuffer, Error>.makeStream()

		Task {
			for data in responseData {
				continuation.yield(data.data)
				try await Task.sleep(for: intermittentSleepDuration)
			}

			continuation.finish()
		}

		return stream
	}

	func mockedStreamingResponse(_ request: HTTPClientRequest) async throws -> AsyncThrowingStream<ByteBuffer, Error> {
		try await superMockedStreamingResponse(request, intermittentSleepDuration: .milliseconds(20))
	}

	@discardableResult
	func validate(method: HTTPMethod, andGetURLFromRequest request: HTTPClientRequest) throws -> URL {
		guard request.method == method else { throw DockerGeneralError.message("require post method") }
		guard
			let url = URL(string: request.url)
		else { throw DockerGeneralError.message("invalid url") }
		return url
	}
	func validate(request: HTTPClientRequest) throws {}
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
