import NIO
import NIOHTTP1
import Foundation
import Logging

public typealias GetContainerLogsEndpoint = GetLogsEndpoint
public struct GetLogsEndpoint: StreamingEndpoint {

	typealias Body = NoBody
	public typealias Response = DockerLogEntry
	var queryArugments: [URLQueryItem] {
		[
			URLQueryItem(name: "stdout", value: stdout.description),
			URLQueryItem(name: "stderr", value: stderr.description),
			URLQueryItem(name: "follow", value: follow.description),
			URLQueryItem(name: "tail", value: tail),
			URLQueryItem(name: "timestamps", value: timestamps.description),
			URLQueryItem(name: "since", value: since.description),
			URLQueryItem(name: "until", value: until.description),
		]
	}

	let method: HTTPMethod = .GET

	let id: String
	let isTTY: Bool
	let follow: Bool
	let tail: String
	let stdout: Bool
	let stderr: Bool
	let timestamps: Bool
	let since: Int64
	let until: Int64
	let logger: Logger

	var path: String {
		"containers/\(id)/logs"
	}

	static var formatter: DateFormatter {
		let format = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSS'Z'"
		let formatter = DateFormatter()
		formatter.dateFormat = format
		return formatter
	}

	init(
		id: String,
		isTTY: Bool,
		stdout: Bool,
		stderr: Bool,
		timestamps: Bool,
		follow: Bool,
		tail: String,
		since: Date,
		until: Date,
		logger: Logger
	) {
		self.id = id
		self.isTTY = isTTY
		self.stdout = stdout
		self.stderr = stderr
		self.timestamps = timestamps
		self.follow = follow
		self.tail = tail
		// TODO: looks like Swift adds an extra zero compared to `docker logs --since=xxx`
		self.since = (since == .distantPast) ? 0 : Int64(since.timeIntervalSince1970)
		self.until = Int64(until.timeIntervalSince1970)
		self.logger = logger
	}

	func mapStreamChunk(
		_ buffer: ByteBuffer,
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
				let (timestamp, logLine) = extractTimestamp(from: string)

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
			let (timestamp, logLine) = extractTimestamp(from: rawString)
			
			return [DockerLogEntry(source: source, timestamp: timestamp, message: logLine)]
		}
	}

	private func extractTimestamp(from logLine: String) -> (Date?, String) {
		guard timestamps else { return (nil, logLine) }

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
