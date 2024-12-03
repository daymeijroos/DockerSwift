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

	package var streamContinuation: AsyncThrowingStream<ByteBuffer, any Error>.Continuation?

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

extension ContainerAttachEndpoint {
	@MainActor
	fileprivate class _HandleImplementation: Sendable, ContainerAttachEndpoint.AttachHandle, ChannelInboundHandler {
		typealias InboundIn = ByteBuffer
		typealias OutboundOut = ByteBuffer

		nonisolated(unsafe)
		var context: ChannelHandlerContext?

		fileprivate var runTask: Task<Void, Never>?

		public weak var delegate: ContainerAttachEndpoint.AttachHandleDelegate?

		public let stream: AsyncThrowingStream<ByteBuffer, Error>
		private let continuation: AsyncThrowingStream<ByteBuffer, Error>.Continuation

		fileprivate init() {
			let (stream, continuation) = AsyncThrowingStream<ByteBuffer, Error>.makeStream()
			self.stream = stream
			self.continuation = continuation
		}

		public func send(_ buffer: ByteBuffer) async throws {
			guard let context = context else { throw DockerError.notconnected }
			let prom = context.eventLoop.makePromise(of: Void.self)
			context.eventLoop.execute { [self] in
				context.writeAndFlush(wrapOutboundOut(buffer), promise: prom)
			}
			try await prom.futureResult.get()
		}

		nonisolated
		func channelActive(context: ChannelHandlerContext) {
			Task {
				await MainActor.run {
					self.context = context
					attachHandleDidConnect(self)
				}
			}
		}

		nonisolated
		func channelRead(context: ChannelHandlerContext, data: NIOAny) {
			Task {
				let byteBuffer = unwrapInboundIn(data)
				await attachHandle(self, didRecieveData: byteBuffer)
			}
		}

		nonisolated
		func errorCaught(context: ChannelHandlerContext, error: any Error) {
			Task {
				await attachHandle(self, didRecieveError: error)
			}
		}

		nonisolated
		func channelInactive(context: ChannelHandlerContext) {
			context.close(promise: nil)
			Task {
				await attachHandleDidDisconnect(self)
			}
		}
	}

	fileprivate class _MockHandleImplementation: Sendable, ContainerAttachEndpoint.AttachHandle {
		weak var delegate: (any ContainerAttachEndpoint.AttachHandleDelegate)?

		let stream: AsyncThrowingStream<ByteBuffer, any Error>

		let mocker: any BidirectionalMockEndpoint

		init(mocker: any BidirectionalMockEndpoint, client: DockerClient) async throws {
			var mocker = mocker

			let req = try mocker.request(
				socketURL: client.daemonURL,
				apiVersion: client.apiVersion,
				additionalHeaders: client.headers,
				encoder: client.encoder)

			let stream = try await mocker.mockedStreamingResponse(req)
			self.mocker = mocker
			self.stream = stream
		}

		func send(_ buffer: ByteBuffer) async throws {
			try await mocker.send(buffer)
		}
	}
}

extension ContainerAttachEndpoint._HandleImplementation: ContainerAttachEndpoint.AttachHandleDelegate {
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

public extension DockerClient.ContainersAPI {
	@MainActor
	func attach(_ endpoint: ContainerAttachEndpoint) async throws -> ContainerAttachEndpoint.AttachHandle {
		var endpoint = endpoint
		guard endpoint.isStarting == false else { throw AttachError.alreadyStarting }
		endpoint.isStarting = true

		if case .testing(useMocks: let useMocks) = client.testMode, useMocks, let mockEndpoint = endpoint as? (any BidirectionalMockEndpoint) {
			let handle = try await ContainerAttachEndpoint._MockHandleImplementation(mocker: mockEndpoint, client: client)

			return handle
		}

		let handle = ContainerAttachEndpoint._HandleImplementation()

		let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
		let bootstrap = ClientBootstrap(group: group)
			.channelInitializer { channel in
				channel.pipeline.addHandler(handle)
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
