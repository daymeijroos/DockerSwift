import NIOHTTP1
import NIO
import NIOFoundationCompat
import Foundation
import AsyncHTTPClient

protocol Endpoint {
	associatedtype Response
	associatedtype Body: Codable
	var path: String { get }
	var method: HTTPMethod { get }
	var queryArugments: [URLQueryItem] { get }
	var headers: HTTPHeaders? {get}
	var body: Body? { get }

	var timeout: TimeAmount? { get }
}

extension Endpoint {
	func request(socketURL url: URL, apiVersion: String, additionalHeaders: HTTPHeaders, encoder: JSONEncoder) throws -> HTTPClientRequest {

		let body = try {
			if let endpointBody = self.body as? ByteBuffer {
				HTTPClientRequest.Body.bytes(endpointBody)
			} else {
				try self.body.map { try HTTPClientRequest.Body.bytes(encoder.encode($0)) }
			}
		}()

		let urlPath = "/\(apiVersion)/\(path)"

		let allHeaders = {
			var start = headers ?? HTTPHeaders()
			start.add(contentsOf: additionalHeaders)
			return start
		}()

		return HTTPClientRequest(
			socketURL: url,
			urlPath: urlPath,
			queryItems: queryArugments,
			method: method,
			body: body,
			headers: allHeaders)
	}
}

protocol SimpleEndpoint: Endpoint where Response: Codable {
	func responseValidation(_ response: Response) throws(DockerGeneralError)
}

extension SimpleEndpoint {
	public var headers: HTTPHeaders? { nil }
	public var body: Body? { nil }
	var timeout: TimeAmount? { .seconds(10) }

	func responseValidation(_ response: Response) throws(DockerGeneralError) {}
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

	var timeout: TimeAmount? { .hours(365 * 24 * 10) }

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

protocol LogStreamCommon: StreamingEndpoint {}
extension LogStreamCommon {
	func mapLogStreamChunk(
		_ buffer: ByteBuffer,
		isTTY: Bool,
		loglineIncludesTimestamps: Bool,
		remainingBytes: inout ByteBuffer
	) async throws(StreamChunkError) -> [DockerLogEntry] {
		guard
			buffer.readableBytes > 0
		else { throw .noValidData }

		var buffer = buffer

		if isTTY {
			var entries: [DockerLogEntry] = []
			let data = Data(buffer: buffer)
			let lines = data.split(separator: [0xd, 0xa]) // crlf

			for line in lines {
				let string = String(decoding: line, as: UTF8.self)
				let (timestamp, logLine) = extractTimestamp(from: string, loglineIncludesTimestamps: loglineIncludesTimestamps)

				entries.append(DockerLogEntry(source: .stdout, timestamp: timestamp, message: logLine))
			}
			return entries
		} else {
			guard
				let sourceRawValue: UInt8 = buffer.readInteger(),
				let source = DockerLogEntry.Source(rawValue: sourceRawValue),
				case _ = buffer.readBytes(length: 3),
				let messageSize: UInt32 = buffer.readInteger(endianness: .big),
				messageSize > 0,
				let messageBytes = buffer.readBytes(length: Int(messageSize))
			else { throw .noValidData }

			let rawString = String(decoding: messageBytes, as: UTF8.self)
			let (timestamp, logLine) = extractTimestamp(from: rawString, loglineIncludesTimestamps: loglineIncludesTimestamps)

			return [DockerLogEntry(source: source, timestamp: timestamp, message: logLine)]
		}
	}

	private func extractTimestamp(from logLine: String, loglineIncludesTimestamps: Bool) -> (Date?, String) {
		guard loglineIncludesTimestamps else { return (nil, logLine) }

		let dateStrSlice = logLine.prefix(while: { $0.isWhitespace == false })
		let	dateStr = String(dateStrSlice)
		guard dateStrSlice.endIndex != logLine.endIndex else {
			if let date = try? DockerDateVarietyStrategy.decode(dateStr) {
				return (date, "")
			} else {
				return (nil, logLine)
			}
		}
		let remaining = logLine.suffix(from: logLine.index(after: dateStrSlice.endIndex))

		guard
			let date = try? DockerDateVarietyStrategy.decode(dateStr)
		else { return (nil, logLine) }
		return (date, String(remaining))
	}
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
							continuation.finish(throwing: DockerGeneralError.unknownResponse("Expected json terminated by line return"))
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

