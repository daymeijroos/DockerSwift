import NIOHTTP1
import NIO
import Foundation

public struct BuildEndpoint: StreamingEndpoint {
	var body: ByteBuffer?

	public typealias Response = StreamOutput
	let method: HTTPMethod = .POST

	private let buildConfig: Configuration

	// Some Query String items have to be encoded as JSON
	private let encoder: JSONEncoder
	// Decode build output message
	private let decoder = JSONDecoder()

	var path: String { "build" }

	var queryArugments: [URLQueryItem] {
		let cacheFrom = try? encoder.encode(buildConfig.cacheFrom)
		let buildArgs = {
			let args = try? encoder.encode(buildConfig.buildArgs)
			return args.map { String(decoding: $0, as: UTF8.self) }
		}()
		let labels = {
			let value = try? encoder.encode(buildConfig.labels)
			return value.map { String(decoding: $0, as: UTF8.self) }
		}()

		let queryItems: [URLQueryItem?] = [
			URLQueryItem(name: "dockerfile", value: "\(buildConfig.dockerfile)"),
			buildConfig.extraHosts.map { URLQueryItem(name: "extrahosts", value: $0) },
			buildConfig.remote.map { URLQueryItem(name: "remote", value: $0.absoluteString) },
			URLQueryItem(name: "q", value: "\(buildConfig.quiet)"),
			URLQueryItem(name: "nocache", value: buildConfig.noCache.description),
			URLQueryItem(name: "cachefrom", value: String(decoding: cacheFrom ?? Data(), as: UTF8.self)),
			URLQueryItem(name: "pull", value: buildConfig.pull.description),
			URLQueryItem(name: "rm", value: buildConfig.rm.description),
			URLQueryItem(name: "forcerm", value: buildConfig.forceRm.description),
			URLQueryItem(name: "memory", value: buildConfig.memory.description),
			URLQueryItem(name: "memswap", value: buildConfig.memorySwap.description),
			URLQueryItem(name: "cpushares", value: buildConfig.cpuShares.description),
			buildConfig.cpusetCpus.map { URLQueryItem(name: "cpusetcpus", value: $0) },
			URLQueryItem(name: "cpuperiod", value: buildConfig.cpuPeriod.description),
			URLQueryItem(name: "cpuquota", value: buildConfig.cpuQuota.description),
			buildConfig.shmSizeBytes.map { URLQueryItem(name: "shmsize", value: $0.description) },
			URLQueryItem(name: "squash", value: buildConfig.squash.description),
			buildConfig.networkMode.map { URLQueryItem(name: "networkmode", value: $0) },
			buildConfig.platform.map { URLQueryItem(name: "platform", value: $0) },
			buildConfig.target.map { URLQueryItem(name: "target", value: $0) },
			buildConfig.outputs.map { URLQueryItem(name: "outputs", value: $0) },
			buildArgs.map { URLQueryItem(name: "buildargs", value: $0) },
			labels.map { URLQueryItem(name: "labels", value: $0) },
		]

		return queryItems.compactMap(\.self) + (buildConfig.repoTags?.map { URLQueryItem(name: "t", value: $0) } ?? [])
	}

	init(buildConfig: Configuration, context: ByteBuffer) {
		self.buildConfig = buildConfig
		self.body = context
		self.encoder = .init()
	}

	func mapStreamChunk(_ buffer: ByteBuffer, remainingBytes: inout ByteBuffer) async throws(StreamChunkError) -> [StreamOutput] {
		try await mapDecodableStreamChunk(buffer, decoder: decoder, remainingBytes: &remainingBytes)
	}
}

public extension BuildEndpoint {
	/// Configuration for a `docker build`.
	struct Configuration: Codable {
		/// Path within the build context to the Dockerfile. This is ignored if `remote` is specified and points to an external Dockerfile.
		public var dockerfile: String = "Dockerfile"

		/// list of names and optional tags to apply to the image, in the `name:tag` format.
		/// If you omit the tag the default `latest` value is assumed.
		public var repoTags: [String]? = []

		/// Extra hosts to add to /etc/hosts
		public var extraHosts: String? = nil

		/// A Git repository URI or HTTP/HTTPS context URI.
		/// If the URI points to a single text file, the file’s contents are placed into a file called Dockerfile and the image is built from that file.
		/// If the URI points to a tarball, the file is downloaded by the daemon and the contents therein used as the context for the build.
		/// If the URI points to a tarball and the dockerfile parameter is also specified, there must be a file with the corresponding path inside the tarball.
		public var remote: URL? = nil

		/// Suppress verbose build output.
		public var quiet: Bool = false

		/// Do not use the cache when building the image.
		public var noCache: Bool = false

		/// List of images used for build cache resolution.
		public var cacheFrom: [String] = []

		/// Attempt to pull the image even if an older image exists locally.
		public var pull: Bool = false

		/// Remove intermediate containers after a successful build.
		public var rm: Bool = true

		/// Always remove intermediate containers, even upon failure.
		public var forceRm: Bool = false

		/// Set memory limit for build.
		public var memory: UInt64 = 0

		/// Total memory (memory + swap). Set as -1 to disable swap.
		public var memorySwap: Int64 = -1

		/// CPU shares (relative weight).
		public var cpuShares: UInt64 = 0

		/// CPUs in which to allow execution (e.g., `0-3`, `0,1`).
		public var cpusetCpus: String? = nil

		/// The length of a CPU period in microseconds.
		public var cpuPeriod: UInt64 = 0

		/// Microseconds of CPU time that the container can get in a CPU period.
		public var cpuQuota: UInt64 = 0

		/// String pairs for build-time variables.
		/// Users pass these values at build-time. Docker uses the buildargs as the environment context for commands run via the Dockerfile `RUN` instruction, or for variable expansion in other Dockerfile instructions.
		/// This is not meant for passing secret values.
		public var buildArgs: [String:String] = [:]

		/// Size of `/dev/shm` in bytes.
		/// The size must be greater than 0. If omitted the system uses 64MB.
		public var shmSizeBytes: UInt64? = nil

		/// Squash the resulting images layers into a single layer. (Experimental release only.)
		public var squash: Bool = false

		/// Arbitrary key/value labels to set on the image
		public var labels: [String:String] = [:]

		/// Sets the networking mode for the run commands during build.
		/// Supported standard values are: `bridge`, `host`, `none`, and `container:<name|id>`.
		/// Any other value is taken as a custom network's name or ID to which this container should connect to.
		public var networkMode: String?

		/// Platform in the format os[/arch[/variant]]
		public var platform: String? = nil

		/// Target build stage
		public var target: String? = nil

		/// BuildKit output configuration
		public var outputs: String? = nil

		public init(
			dockerfile: String = "Dockerfile",
			repoTags: [String]? = [],
			extraHosts: String? = nil,
			remote: URL? = nil,
			quiet: Bool = false,
			noCache: Bool = false,
			cacheFrom: [String] = [],
			pull: Bool = false,
			rm: Bool = true,
			forceRm: Bool = false,
			memory: UInt64 = 0,
			memorySwap: Int64 = -1,
			cpuShares: UInt64 = 0,
			cpusetCpus: String? = nil,
			cpuPeriod: UInt64 = 0,
			cpuQuota: UInt64 = 0,
			buildArgs: [String : String] = [:],
			shmSizeBytes: UInt64? = nil,
			squash: Bool = false,
			labels: [String : String] = [:],
			networkMode: String? = nil,
			platform: String? = nil,
			target: String? = nil,
			outputs: String? = nil
		) {
			self.dockerfile = dockerfile
			self.repoTags = repoTags
			self.extraHosts = extraHosts
			self.remote = remote
			self.quiet = quiet
			self.noCache = noCache
			self.cacheFrom = cacheFrom
			self.pull = pull
			self.rm = rm
			self.forceRm = forceRm
			self.memory = memory
			self.memorySwap = memorySwap
			self.cpuShares = cpuShares
			self.cpusetCpus = cpusetCpus
			self.cpuPeriod = cpuPeriod
			self.cpuQuota = cpuQuota
			self.buildArgs = buildArgs
			self.shmSizeBytes = shmSizeBytes
			self.squash = squash
			self.labels = labels
			self.networkMode = networkMode
			self.platform = platform
			self.target = target
			self.outputs = outputs
		}
	}
}

public extension BuildEndpoint {
	/// Represents a Docker build output message
	struct StreamOutput: Codable {
		/// Raw message from the Docker builder
		public let stream: String?

		/// Additional information. Used to return the built Image ID.
		public let aux: AuxInfo?

		/// Set if build error, nil otherwise
		public let message: String?

		public struct AuxInfo: Codable {
			/// The ID of the built image
			public let id: String

			enum CodingKeys: String, CodingKey {
				case id = "ID"
			}
		}
	}
}
