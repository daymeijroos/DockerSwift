import NIOHTTP1
import NIO
import NIOFoundationCompat
import Foundation

protocol Endpoint {
	associatedtype Response
	associatedtype Body: Codable
	var path: String { get }
	var method: HTTPMethod { get }
	var queryArugments: [URLQueryItem] { get }
	var headers: HTTPHeaders? {get}
	var body: Body? { get }
}

protocol SimpleEndpoint: Endpoint where Response: Codable {
	func responseValidation(_ response: Response) throws(DockerError)
}

extension SimpleEndpoint {
	public var headers: HTTPHeaders? { nil }
	public var body: Body? { nil }
	
	func responseValidation(_ response: Response) throws(DockerError) {}
}

enum StreamChunkError: Error {
	case noValidData
	case decodeError(Error)
}

protocol StreamingEndpoint: Endpoint {
	func mapStreamChunk(_ buffer: ByteBuffer, remainingBytes: inout ByteBuffer) async throws(StreamChunkError) -> [Response]
}

extension StreamingEndpoint {
	var headers: HTTPHeaders? { nil }
	var body: Body? { nil }

	func mapDecodableStreamChunk(_ buffer: ByteBuffer, decoder: JSONDecoder, remainingBytes: inout ByteBuffer) async throws(StreamChunkError) -> [Response] where Response: Decodable {
		var buffer = buffer
		guard
			buffer.readableBytes > 0
		else { return [] }
		guard
			let data = buffer.readData(length: buffer.readableBytes),
			case let chunks = data.split(separator: "\n".utf8.first!),
			chunks.isEmpty == false
		else { throw .noValidData }

		var output: [Response] = []
		for (index, chunk) in chunks.enumerated() {
			do {
				let decoded = try decoder.decode(Response.self, from: chunk)
				output.append(decoded)
			} catch {
				guard index == chunks.count - 1 else {
					throw .decodeError(error)
				}
				remainingBytes.writeBytes(chunk)
			}
		}
		return output
	}
}

protocol PipelineEndpoint: StreamingEndpoint {
	associatedtype FinalResponse

	func finalize(_ parts: [Response]) async throws -> FinalResponse
}

@available(*, deprecated)
/// A Docker API endpoint that returns  a progressive stream of JSON objects separated by line returns
public class JSONStreamingEndpoint<T>: StreamingEndpoint where T: Codable {
	internal init(path: String, method: HTTPMethod = .GET) {
		self.path = path
		self.method = method
	}
	
	private(set) internal var path: String
	var queryArugments: [URLQueryItem] { [] }

	private(set) internal var method: HTTPMethod = .GET
	
	typealias Response = AsyncThrowingStream<ByteBuffer, Error>
	
	typealias Body = NoBody
	
	private let decoder = JSONDecoder()

	func mapStreamChunk(_ buffer: ByteBuffer, remainingBytes: inout ByteBuffer) async throws(StreamChunkError) -> [AsyncThrowingStream<ByteBuffer, any Error>] {
		fatalError()
	}

	func map(response: Response, as: T.Type) async throws -> AsyncThrowingStream<T, Error>  {
		return AsyncThrowingStream<T, Error> { continuation in
			Task {
				for try await var buffer in response {
					let totalDataSize = buffer.readableBytes
					while buffer.readerIndex < totalDataSize {
						if buffer.readableBytes == 0 {
							continuation.finish()
						}
						guard let data = buffer.readData(length: buffer.readableBytes) else {
							continuation.finish(throwing: DockerLogDecodingError.dataCorrupted("Unable to read \(totalDataSize) bytes as Data"))
							return
						}
						let splat = data.split(separator: 10 /* ascii code for \n */)
						guard splat.count >= 1 else {
							continuation.finish(throwing: DockerError.unknownResponse("Expected json terminated by line return"))
							return
						}
						do {
							let model = try decoder.decode(T.self, from: splat.first!)
							continuation.yield(model)
						}
						catch(let error) {
							continuation.finish(throwing: error)
						}
					}
				}
				continuation.finish()
			}
		}
	}
}

