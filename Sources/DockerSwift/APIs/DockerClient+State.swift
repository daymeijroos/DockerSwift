public extension DockerClient {
	enum State {
		case uninitialized
		case initialized(HostInfo)

		public var hostInfo: HostInfo? {
			switch self {
			case .uninitialized:
				nil
			case .initialized(let info):
				info
			}
		}
	}

	struct HostInfo: Codable, Sendable, Hashable {
		let architecture: Architecture
		let version: String
		let isExperimentalBuild: Bool
		let os: OsType
		let engine: HostEngine

		public struct HostEngine: RawRepresentable, Codable, Hashable, Sendable {
			public static let docker = HostEngine(rawValue: "Engine")
			public static let podman = HostEngine(rawValue: "Podman Engine")

			public let rawValue: String

			public init(rawValue: String) {
				self.rawValue = rawValue
			}
		}
	}
}
