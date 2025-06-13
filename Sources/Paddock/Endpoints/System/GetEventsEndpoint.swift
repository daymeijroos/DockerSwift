import Foundation
import BetterCodable
import NIO
import NIOHTTP1

public struct GetEventsEndpoint: StreamingEndpoint {
	private static let decoder = JSONDecoder()
	typealias Body = NoBody

	var path: String { "events" }

	let method: HTTPMethod = .GET

	var queryArugments: [URLQueryItem] {
		[
			since.map { URLQueryItem(name: "since", value: Int($0.timeIntervalSince1970).description) },
			until.map { URLQueryItem(name: "until", value: Int($0.timeIntervalSince1970).description) },
		]
			.compactMap(\.self)
	}

	let since: Date?
	let until: Date?

	func mapStreamChunk(_ buffer: ByteBuffer, remainingBytes: inout ByteBuffer) async throws(StreamChunkError) -> [Response] {
		try await mapDecodableStreamChunk(buffer, decoder: Self.decoder, remainingBytes: &remainingBytes)
	}

	public struct Response: Codable {
		/// The type of object emitting the event
		public let type: EventType

		/// The type of event
		public let action: EventAction

		/// Scope of the event. Engine events are `local` scope. Cluster (Swarm) events are `swarm` scope.
		public let scope: EventScope

		public let actor: EventActor

		@DateValue<TimestampStrategy>
		private(set) public var time: Date

		enum CodingKeys: String, CodingKey {
			case type = "Type"
			case action = "Action"
			case scope = "scope"
			case actor = "Actor"
			case time = "time"
		}

		public enum EventType: String, Codable {
			case builder, config, container, daemon, image, network, node, plugin, secret, service, volume
		}

		public enum EventAction: String, Codable {
			// Container actions (some also exist for images, volumes, ...)
			case attach, commit, copy, create, destroy, detach, die, exec_create, exec_detach, exec_start, exec_die, export, health_status, kill, oom, pause, rename, resize, restart, start, stop, top, unpause, update, prune
			// Image actions
			case delete, `import`, load, pull, push, save, tag, untag

			// Volume actions
			case mount, unmount

			// Network actions
			case connect, disconnect, remove

			// Docker daemon
			case reload
		}

		public enum EventScope: String, Codable {
			case local, swarm
		}

		public struct EventActor: Codable {
			public let id: String
			public let attributes: [String:String]?

			enum CodingKeys: String, CodingKey {
				case id = "ID"
				case attributes = "Attributes"
			}
		}
	}
}

