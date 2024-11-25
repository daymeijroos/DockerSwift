import Foundation
import NIOHTTP1
import NIO

public struct WaitContainerEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = ContainerWaitResponse
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] {
		[
			condition.map { URLQueryItem(name: "condition", value: $0.rawValue) },
			formattedInterval.map { URLQueryItem(name: "interval", value: $0) },
		]
			.compactMap(\.self)
	}

	let nameOrId: String
	/// wait until container is to a given condition. default is `.stopped`(podman)/`.notRunning`(docker)
	let condition: Condition?
	/// Time Interval to wait before polling for completion.
	/// Only listed in podman api docs
	let interval: TimeAmount?

	private var formattedInterval: String? {
		guard let interval else { return nil }
		let ms = interval.nanoseconds / 1_000_000
		return "\(ms)ms"
	}

	init(nameOrId: String, condition: Condition?, interval: TimeAmount?) {
		self.nameOrId = nameOrId
		self.condition = condition
		self.interval = interval
	}
	
	var path: String {
		"containers/\(nameOrId)/wait"
	}

	/// Condition enumerations differ in podman and docker docs. it's unclear if these values are cross
	/// compatible or if you need to use the specific docker compatible values with docker and podman
	/// compatible with podman, so each preconfigured value is annotated with which documentation it comes from.
	public struct Condition: RawRepresentable, Codable, Sendable, Hashable {
		/// from docker api docs
		public static let notRunning = Condition(rawValue: "not-running")
		/// from docker api docs
		public static let nextExit = Condition(rawValue: "next-exit")
		/// from docker api docs
		public static let removed = Condition(rawValue: "removed")
		/// from podman api docs
		public static let configured = Condition(rawValue: "configured")
		/// from podman api docs
		public static let created = Condition(rawValue: "created")
		/// from podman api docs
		public static let exited = Condition(rawValue: "exited")
		/// from podman api docs
		public static let paused = Condition(rawValue: "paused")
		/// from podman api docs
		public static let running = Condition(rawValue: "running")
		/// from podman api docs
		public static let stopped = Condition(rawValue: "stopped")

		public let rawValue: String

		public init(rawValue: String) {
			self.rawValue = rawValue
		}
	}

	struct ContainerWaitResponse: Codable {
		let statusCode: Int

		enum CodingKeys: String, CodingKey {
			case statusCode = "StatusCode"
		}
	}
}
