import Foundation
import AsyncHTTPClient
@preconcurrency import NIO
import NIOHTTP1

public struct ContainerAttachEndpoint: LogStreamCommon {
	typealias Response = DockerLogEntry

	typealias Body = NoBody

	public var path: String { "containers/\(containerID)/attach" }
	public let method: HTTPMethod = .POST

	public let containerID: String
	public let containerWithTTY: Bool

	public let detachKeys: String?
	public let logs: Bool?
	public let stream: Bool?
	public let stdin: Bool?
	public let stdout: Bool?
	public let stderr: Bool?

	public init(
		containerID: String,
		containerWithTTY: Bool,
		detachKeys: String? = nil,
		logs: Bool? = nil,
		stream: Bool? = nil,
		stdin: Bool? = nil,
		stdout: Bool? = nil,
		stderr: Bool? = nil
	) {
		self.containerID = containerID
		self.containerWithTTY = containerWithTTY
		self.detachKeys = detachKeys
		self.logs = logs
		self.stream = stream
		self.stdin = stdin
		self.stdout = stdout
		self.stderr = stderr
	}

	public var queryArugments: [URLQueryItem] {
		[
			detachKeys.map { URLQueryItem(name: "detachKeys", value: $0) },
			logs.map { URLQueryItem(name: "logs", value: $0.description) },
			stream.map { URLQueryItem(name: "stream", value: $0.description) },
			stdin.map { URLQueryItem(name: "stdin", value: $0.description) },
			stdout.map { URLQueryItem(name: "stdout", value: $0.description) },
			stderr.map { URLQueryItem(name: "stderr", value: $0.description) },
		]
			.compactMap(\.self)
	}

	func mapStreamChunk(
		_ buffer: ByteBuffer,
		remainingBytes: inout ByteBuffer
	) async throws(StreamChunkError) -> [DockerLogEntry] {
		try await mapLogStreamChunk(
			buffer,
			isTTY: containerWithTTY,
			loglineIncludesTimestamps: false,
			remainingBytes: &remainingBytes)
	}

	@MainActor
	fileprivate var isStarting = false

	@MainActor
	public protocol AttachHandle: Sendable, AnyObject {
		var delegate: AttachHandleDelegate? { get set }

		var stream: AsyncThrowingStream<ByteBuffer, Error> { get }

		func send(_ buffer: ByteBuffer) async throws
	}

	@MainActor
	public protocol AttachHandleDelegate: AnyObject {
		func attachHandleDidConnect(_ attachHandle: AttachHandle)
		func attachHandle(_ attachHandle: AttachHandle, didRecieveData byteBuffer: ByteBuffer)
		func attachHandle(_ attachHandle: AttachHandle, didRecieveError error: Error)
		func attachHandleDidDisconnect(_ attachHandle: AttachHandle)
	}
}

public extension ContainerAttachEndpoint.AttachHandle {
	func send(_ string: String) async throws {
		let buffer = ByteBuffer(string: string)
		return try await send(buffer)
	}
}

public extension DockerClient.ContainersAPI {
	@MainActor
	func attach(_ endpoint: consuming ContainerAttachEndpoint) async throws -> ContainerAttachEndpoint.AttachHandle {
		guard endpoint.isStarting == false else { throw AttachError.alreadyStarting }
		endpoint.isStarting = true

		let privateHandler = ContainerAttachHandle._Handler()
		let handle = ContainerAttachHandle(handler: privateHandler)

		let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
		let bootstrap = ClientBootstrap(group: group)
			.channelInitializer { channel in
				channel.pipeline.addHandler(privateHandler)
			}
			.channelOption(.socketOption(.so_reuseaddr), value: 1)

		guard
			let socketPath = client.daemonURL.host(percentEncoded: false)
		else { throw DockerError.message("Invalid unix domain socket path: \(client.daemonURL)") }
		let channel = try await bootstrap.connect(unixDomainSocketPath: socketPath).get()

		defer { endpoint.isStarting = false }
		let runTask = Task {
			do {
				try await channel.closeFuture.get()
			} catch {
				fatalError("Error connecting to server: \(error)")
			}
		}
		handle.runTask = runTask

		let pathGen = {
			let url = client
				.daemonURL
				.appending(path: endpoint.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
			guard endpoint.queryArugments.isEmpty == false else { return url.path() }
			let withQuery = url.appending(queryItems: endpoint.queryArugments)
			return "\(withQuery.path())?\(withQuery.query() ?? "")"
		}()
		let headerLines = [
			"\(endpoint.method.rawValue) \(pathGen) HTTP/1.1",
			"Host: localhost",
		]

		let header = headerLines
			.joined(by: "\r\n") + "\r\n\r\n"

		try await handle.send(header)

		return handle
	}

	enum AttachError: Swift.Error {
		case alreadyStarting
	}
}

@MainActor
public class ContainerAttachHandle: Sendable, ContainerAttachEndpoint.AttachHandle {
	private let handler: _Handler
	fileprivate var runTask: Task<Void, Never>?

	public weak var delegate: ContainerAttachEndpoint.AttachHandleDelegate?

	public let stream: AsyncThrowingStream<ByteBuffer, Error>
	private let continuation: AsyncThrowingStream<ByteBuffer, Error>.Continuation

	fileprivate init(handler: _Handler) {
		let (stream, continuation) = AsyncThrowingStream<ByteBuffer, Error>.makeStream()
		self.stream = stream
		self.continuation = continuation
		self.handler = handler
		handler.parent = self
	}

	public func send(_ buffer: ByteBuffer) async throws {
		guard let context = handler.context else { throw DockerError.notconnected }
		let prom = context.eventLoop.makePromise(of: Void.self)
		context.eventLoop.execute { [handler] in
			guard let context = handler.context else { return prom.fail(DockerError.notconnected) }
			context.writeAndFlush(handler.wrapOutboundOut(buffer), promise: prom)
		}
		try await prom.futureResult.get()
	}

	fileprivate final class _Handler: ChannelInboundHandler, Sendable {
		typealias InboundIn = ByteBuffer
		typealias OutboundOut = ByteBuffer

		nonisolated(unsafe)
		weak var parent: ContainerAttachHandle!

		nonisolated(unsafe)
		var context: ChannelHandlerContext?

		func channelActive(context: ChannelHandlerContext) {
			Task {
				await MainActor.run {
					self.context = context
					parent?.attachHandleDidConnect(parent)
				}
			}
		}

		func channelRead(context: ChannelHandlerContext, data: NIOAny) {
			Task {
				let byteBuffer = unwrapInboundIn(data)
				await parent?.attachHandle(parent, didRecieveData: byteBuffer)
			}
		}

		func errorCaught(context: ChannelHandlerContext, error: any Error) {
			Task {
				await parent?.attachHandle(parent, didRecieveError: error)
			}
		}

		func channelInactive(context: ChannelHandlerContext) {
			context.close(promise: nil)
			Task {
				await parent?.attachHandleDidDisconnect(parent)
			}
		}
	}
}

extension ContainerAttachHandle: ContainerAttachEndpoint.AttachHandleDelegate {
	public func attachHandleDidConnect(_ containerAttachHandle: ContainerAttachEndpoint.AttachHandle) {
		delegate?.attachHandleDidConnect(self)
	}
	
	public func attachHandle(_ containerAttachHandle: ContainerAttachEndpoint.AttachHandle, didRecieveData byteBuffer: ByteBuffer) {
		delegate?.attachHandle(self, didRecieveData: byteBuffer)
		continuation.yield(byteBuffer)
	}
	
	public func attachHandle(_ containerAttachHandle: ContainerAttachEndpoint.AttachHandle, didRecieveError error: any Error) {
		delegate?.attachHandle(self, didRecieveError: error)
		continuation.finish(throwing: error)
	}
	
	public func attachHandleDidDisconnect(_ containerAttachHandle: ContainerAttachEndpoint.AttachHandle) {
		delegate?.attachHandleDidDisconnect(self)
		continuation.finish()
	}
}

extension ChannelHandlerContext: @retroactive @unchecked Sendable {}
