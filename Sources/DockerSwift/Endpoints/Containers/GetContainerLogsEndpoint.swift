import NIO
import NIOHTTP1
import Foundation

public class GetContainerLogsEndpoint: StreamingEndpoint {

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

	let container: Container
	let follow: Bool
	let tail: String
	let stdout: Bool
	let stderr: Bool
	let timestamps: Bool
	let since: Int64
	let until: Int64

	var path: String {
		"containers/\(container.id)/logs"
	}

	static var formatter: DateFormatter {
		let format = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSS'Z'"
		let formatter = DateFormatter()
		formatter.dateFormat = format
		return formatter
	}

	init(
		container: Container,
		stdout: Bool,
		stderr: Bool,
		timestamps: Bool,
		follow: Bool,
		tail: String,
		since: Date,
		until: Date
	) {
		self.container = container
		self.stdout = stdout
		self.stderr = stderr
		self.timestamps = timestamps
		self.follow = follow
		self.tail = tail
		// TODO: looks like Swift adds an extra zero compared to `docker logs --since=xxx`
		self.since = (since == .distantPast) ? 0 : Int64(since.timeIntervalSince1970)
		self.until = Int64(until.timeIntervalSince1970)
	}

	func mapStreamChunk(
		_ buffer: ByteBuffer,
		remainingBytes: inout ByteBuffer
	) async throws(StreamChunkError) -> [DockerLogEntry] {
		guard
			buffer.readableBytes > 0
		else { throw .noValidData }

		var buffer = buffer

		let tty = container.config.tty
		if tty {
			do {
				var entries: [DockerLogEntry] = []
				for entry in try DockerStream.getEntryTty(buffer: &buffer, timestamps: timestamps) {
					entries.append(entry)
				}
				return entries
			} catch {
				throw .decodeError(error)
			}
		} else {
			do {
				return try [DockerStream.getEntryNoTty(buffer: &buffer, timestamps: timestamps)]
			} catch {
				throw .decodeError(error)
			}
		}
	}
}
