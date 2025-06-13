import NIOHTTP1

public extension PaddockClient {
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
		let version: String
		let apiVersion: String
		let isExperimentalBuild: Bool
		let os: OsType
		let engine: HostEngine

/*
Api-Version: 1.41
Server: Libpod/5.2.3 (linux)
Date: Sun, 24 Nov 2024 04:17:25 GMT
Content-Length: 983

 Libpod-Api-Version: 5.2.3
*/

/*
Api-Version: 1.47
Server: Docker/27.3.1 (linux)
Date: Sun, 24 Nov 2024 04:17:17 GMT
Content-Length: 822

 Docker-Experimental: false
 Ostype: linux
*/

		init(from header: HTTPHeaders) throws(DockerGeneralError) {
			guard
				let serverString = header.first(name: "Server")
			else { throw DockerGeneralError.unknownResponse("Header missing crucial information") }

			let serverRegex = /^(?<engine>.*)\/(?<version>\S+) \((?<osHost>.*)\)$/

			guard
				let matches = serverString.firstMatch(of: serverRegex)?.output
			else { throw DockerGeneralError.unknownResponse("Header data malformatted") }

			let engine = HostEngine(rawValue: String(matches.engine))
			let version = String(matches.version)
			guard
				let osHost = (OsType(rawValue: String(matches.osHost)) ?? header.first(name: "Ostype").flatMap(OsType.init(rawValue:))),
				let apiVersion = header.first(name: "Api-Version")
			else { throw DockerGeneralError.unknownResponse("Header missing information") }

			let isExperimental = header.first(name: "Docker-Experimental") == "true"
			self.init(
				version: version,
				apiVersion: apiVersion,
				isExperimentalBuild: isExperimental,
				os: osHost,
				engine: engine)
		}

		init(
			version: String,
			apiVersion: String,
			isExperimentalBuild: Bool,
			os: OsType,
			engine: HostEngine
		) {
			self.version = version
			self.apiVersion = apiVersion
			self.isExperimentalBuild = isExperimentalBuild
			self.os = os
			self.engine = engine
		}

		public struct HostEngine: RawRepresentable, Codable, Hashable, Sendable {
			public static let docker = HostEngine(rawValue: "Docker")
			public static let podman = HostEngine(rawValue: "Libpod")

			public let rawValue: String

			public init(rawValue: String) {
				self.rawValue = rawValue
			}
		}
	}
}
