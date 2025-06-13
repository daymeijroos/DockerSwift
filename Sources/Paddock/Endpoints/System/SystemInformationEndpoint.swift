import NIOHTTP1
import Foundation
import BetterCodable

public struct SystemInformationEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	var queryArugments: [URLQueryItem] { [] }

	let method: HTTPMethod = .GET
	let path: String = "info"
}

public extension SystemInformationEndpoint {
	// MARK: - SystemInformationResponse
	struct Response: Codable {
		public init(
			id: String,
			containers: UInt,
			containersRunning: UInt,
			containersPaused: UInt,
			containersStopped: UInt,
			images: UInt,
			storageDriver: String,
			storageDriverStatus: [[String]],
			dockerRootDir: String,
			plugins: Plugins? = nil,
			memoryLimit: Bool,
			swapLimit: Bool,
			kernelMemoryTCP: Bool? = nil,
			cpuCfsPeriod: Bool,
			cpuCfsQuota: Bool,
			cpuShares: Bool,
			cpuSet: Bool,
			pidsLimit: Bool,
			oomKillDisable: Bool,
			iPv4Forwarding: Bool,
			bridgeNfIptables: Bool,
			bridgeNfIp6Tables: Bool,
			debug: Bool,
			nFD: UInt,
			nGoroutines: UInt,
			systemTime: Date,
			loggingDriver: String,
			cgroupDriver: CgroupDriver,
			cgroupVersion: String,
			nEventsListener: Int,
			kernelVersion: String,
			operatingSystem: String,
			osVersion: String,
			osType: OsType,
			architecture: Architecture,
			ncpu: UInt16,
			memTotal: UInt64,
			indexServerAddress: String,
			registryConfig: RegistryConfig,
			genericResources: [GenericResource]? = nil,
			httpProxy: String,
			httpsProxy: String,
			noProxy: String,
			name: String,
			labels: [String],
			experimentalBuild: Bool,
			serverVersion: String,
			runtimes: Runtimes? = nil,
			defaultRuntime: String,
			liveRestoreEnabled: Bool,
			isolation: Isolation = .default,
			initBinary: String,
			containerdCommit: Commit,
			runcCommit: Commit,
			initCommit: Commit,
			securityOptions: [String],
			productLicense: String? = nil,
			defaultAddressPools: [DefaultAddressPool]? = nil,
			warnings: [String]? = nil,
			cdiSpecDirs: [String] = [],
			containerd: ContainerdInfo
		) {
			self.id = id
			self.containers = containers
			self.containersRunning = containersRunning
			self.containersPaused = containersPaused
			self.containersStopped = containersStopped
			self.images = images
			self.storageDriver = storageDriver
			self.storageDriverStatus = storageDriverStatus
			self.dockerRootDir = dockerRootDir
			self.plugins = plugins
			self.memoryLimit = memoryLimit
			self.swapLimit = swapLimit
			self.kernelMemoryTCP = kernelMemoryTCP
			self.cpuCfsPeriod = cpuCfsPeriod
			self.cpuCfsQuota = cpuCfsQuota
			self.cpuShares = cpuShares
			self.cpuSet = cpuSet
			self.pidsLimit = pidsLimit
			self.oomKillDisable = oomKillDisable
			self.iPv4Forwarding = iPv4Forwarding
			self.bridgeNfIptables = bridgeNfIptables
			self.bridgeNfIp6Tables = bridgeNfIp6Tables
			self.debug = debug
			self.nFD = nFD
			self.nGoroutines = nGoroutines
			self.systemTime = systemTime
			self.loggingDriver = loggingDriver
			self.cgroupDriver = cgroupDriver
			self.cgroupVersion = cgroupVersion
			self.nEventsListener = nEventsListener
			self.kernelVersion = kernelVersion
			self.operatingSystem = operatingSystem
			self.osVersion = osVersion
			self.osType = osType
			self.architecture = architecture
			self.ncpu = ncpu
			self.memTotal = memTotal
			self.indexServerAddress = indexServerAddress
			self.registryConfig = registryConfig
			self.genericResources = genericResources
			self.httpProxy = httpProxy
			self.httpsProxy = httpsProxy
			self.noProxy = noProxy
			self.name = name
			self.labels = labels
			self.experimentalBuild = experimentalBuild
			self.serverVersion = serverVersion
			self.runtimes = runtimes
			self.defaultRuntime = defaultRuntime
			self.liveRestoreEnabled = liveRestoreEnabled
			self.isolation = isolation
			self.initBinary = initBinary
			self.containerdCommit = containerdCommit
			self.runcCommit = runcCommit
			self.initCommit = initCommit
			self.securityOptions = securityOptions
			self.productLicense = productLicense
			self.defaultAddressPools = defaultAddressPools
			self.warnings = warnings
			self.cdiSpecDirs = cdiSpecDirs
			self.containerd = containerd
		}

		/// Unique identifier of the daemon.
		public let id: String

		/// Total number of containers on the host.
		public let containers: UInt

		/// Number of containers with status "running".
		public let containersRunning: UInt

		/// Number of containers with status "paused".
		public let containersPaused: UInt

		/// Number of containers with status "stopped".
		public let containersStopped: UInt

		/// Total number of images on the host. Both tagged and untagged (dangling) images are counted.
		public let images: UInt

		/// Name of the storage driver in use.
		public let storageDriver: String

		/// Information specific to the storage driver, provided as "label" / "value" pairs.
		public let storageDriverStatus: [[String]]

		/// Root directory of persistent Docker state. Defaults to `/var/lib/docker` on Linux, and `C:\ProgramData\docker` on Windows.
		public let dockerRootDir: String

		/// Available plugins per type.
		/// Note: Only unmanaged (V1) plugins are included in this list. V1 plugins are "lazily" loaded, and are not returned in this list if there is no resource using the plugin.
		public let plugins: Plugins?

		/// Indicates if the host has memory limit support enabled.
		public let memoryLimit: Bool

		/// Indicates if the host has memory swap limit support enabled.
		public let swapLimit: Bool

		/// Indicates if the host has kernel memory TCP limit support enabled.
		/// Kernel memory TCP limits are not supported when using cgroups v2, which does not support the corresponding `memory.kmem.tcp.limit_in_bytes` cgroup.
		public let kernelMemoryTCP: Bool?

		/// Indicates if CPU CFS (Completely Fair Scheduler) period is supported by the host.
		public let cpuCfsPeriod: Bool

		/// Indicates if CPU CFS (Completely Fair Scheduler) quota is supported by the host.
		public let cpuCfsQuota: Bool

		/// Indicates if CPU Shares limiting is supported by the host.
		public let cpuShares: Bool

		/// Indicates if CPUsets (`cpuset.cpus`, `cpuset.mems`) are supported by the host.
		public let cpuSet: Bool

		/// Indicates if the host kernel has PID limit support enabled.
		public let pidsLimit: Bool

		/// Indicates if disabling the OOM killer is supported on the host.
		public let oomKillDisable: Bool

		/// Indicates IPv4 forwarding is enabled.
		public let iPv4Forwarding: Bool

		/// Indicates if `bridge-nf-call-iptables` is available on the host.
		public let bridgeNfIptables: Bool

		/// Indicates if `bridge-nf-call-ip6tables` is available on the host.
		public let bridgeNfIp6Tables: Bool

		/// Indicates if the daemon is running in debug-mode / with debug-level logging enabled.
		public let debug: Bool

		/// The total number of file Descriptors in use by the daemon process.
		/// This information is only returned if debug-mode is enabled.
		public let nFD: UInt

		/// The number of goroutines that currently exist.
		/// This information is only returned if debug-mode is enabled.
		public let nGoroutines: UInt

		/// Current system-time in RFC 3339 format with nano-seconds.
		@DateValue<DockerDateVarietyStrategy>
		public var systemTime: Date

		/// The logging driver to use as a default for new containers.
		public let loggingDriver: String

		/// The cgroup driver the daemon is using; cgroupfs or systemd.
		/// Returns `none` when the daemon is running in rootless mode
		public let cgroupDriver: CgroupDriver

		/// The cgroup version
		public let cgroupVersion: String

		public let nEventsListener: Int
		public let kernelVersion, operatingSystem, osVersion: String

		public let osType: OsType

		/// Hardware architecture of the host, as returned by the Go runtime (GOARCH).
		public let architecture: Architecture

		/// The number of logical CPUs usable by the daemon.
		public let ncpu: UInt16

		/// Total amount of physical memory available on the host, in bytes.
		public let memTotal: UInt64

		/// Address / URL of the index server that is used for image search, and as a default for user authentication for Docker Hub and Docker Cloud.
		/// Default: "https://index.docker.io/v1/"
		public let indexServerAddress: String

		public let registryConfig: RegistryConfig

		/// User-defined resources can be either Integer resources (e.g, SSD=3) or String resources (e.g, GPU=UUID1).
		public let genericResources: [GenericResource]?

		/// HTTP proxy configured for the daemon. This value is obtained from the `HTTP_PROXY` environment variable. Credentials (user info component) in the proxy URL are masked in the API response.
		/// Note: Containers do not automatically inherit this configuration.
		public let httpProxy: String

		/// HTTPS proxy configured for the daemon. This value is obtained from the `HTTPS_PROXY` environment variable. Credentials (user info component) in the proxy URL are masked in the API response.
		/// Note: Containers do not automatically inherit this configuration.
		public let httpsProxy: String

		/// Comma-separated list of domain extensions for which no proxy should be used. This value is obtained from the `NO_PROXY` environment variable.
		/// Note: Containers do not automatically inherit this configuration.
		public let noProxy: String

		/// Hostname of the host where the Docker daemon is running.
		public let name: String

		@DefaultEmptyArray
		public var labels: [String]

		/// Indicates if experimental features are enabled on the daemon.
		public let experimentalBuild: Bool

		/// Version string of the daemon.
		public let serverVersion: String

		public let runtimes: Runtimes?

		/// Name of the default OCI runtime that is used when starting containers.
		/// The default can be overridden per-container at create time.
		public let defaultRuntime: String

		/// Indicates if live restore is enabled.
		/// If enabled, containers are kept running when the daemon is shutdown or upon daemon start if running containers are detected.
		public let liveRestoreEnabled: Bool

		/// Represents the isolation technology to use as a default for containers. The supported values are platform-specific.
		/// Valid values: "default" "hyperv" "process"
		public let isolation: Isolation

		/// Name and optional, path of the `docker-init` binary.
		public let initBinary: String

		public let containerdCommit, runcCommit, initCommit: Commit

		/// List of security features that are enabled on the daemon, such as apparmor, seccomp, SELinux, user-namespaces (userns), and rootless.
		public let securityOptions: [String]

		/// Reports a summary of the product license on the daemon.
		/// If a commercial license has been applied to the daemon, information such as number of nodes, and expiration are included.
		public let productLicense: String?

		/// List of custom default address pools for local networks, which can be specified in the daemon.json file or dockerd option.
		/// Example: a Base "10.10.0.0/16" with Size 24 will define the set of 256 10.10.[0-255].0/24 address pools.
		public let defaultAddressPools: [DefaultAddressPool]?

		/// List of warnings / informational messages about missing features, or issues related to the daemon configuration.
		public let warnings: [String]?

		@DefaultEmptyArray
		public var cdiSpecDirs: [String]

		public let containerd: ContainerdInfo?

		enum CodingKeys: String, CodingKey {
			case id = "ID"
			case containers = "Containers"
			case containersRunning = "ContainersRunning"
			case containersPaused = "ContainersPaused"
			case containersStopped = "ContainersStopped"
			case images = "Images"
			case storageDriver = "Driver"
			case storageDriverStatus = "DriverStatus"
			case dockerRootDir = "DockerRootDir"
			case plugins = "Plugins"
			case memoryLimit = "MemoryLimit"
			case swapLimit = "SwapLimit"
			case kernelMemoryTCP = "KernelMemoryTCP"
			case cpuCfsPeriod = "CpuCfsPeriod"
			case cpuCfsQuota = "CpuCfsQuota"
			case cpuShares = "CPUShares"
			case cpuSet = "CPUSet"
			case pidsLimit = "PidsLimit"
			case oomKillDisable = "OomKillDisable"
			case iPv4Forwarding = "IPv4Forwarding"
			case bridgeNfIptables = "BridgeNfIptables"
			case bridgeNfIp6Tables = "BridgeNfIp6tables"
			case debug = "Debug"
			case nFD = "NFd"
			case nGoroutines = "NGoroutines"
			case systemTime = "SystemTime"
			case loggingDriver = "LoggingDriver"
			case cgroupDriver = "CgroupDriver"
			case cgroupVersion = "CgroupVersion"
			case nEventsListener = "NEventsListener"
			case kernelVersion = "KernelVersion"
			case operatingSystem = "OperatingSystem"
			case osVersion = "OSVersion"
			case osType = "OSType"
			case architecture = "Architecture"
			case ncpu = "NCPU"
			case memTotal = "MemTotal"
			case indexServerAddress = "IndexServerAddress"
			case registryConfig = "RegistryConfig"
			case genericResources = "GenericResources"
			case httpProxy = "HttpProxy"
			case httpsProxy = "HttpsProxy"
			case noProxy = "NoProxy"
			case name = "Name"
			case labels = "Labels"
			case experimentalBuild = "ExperimentalBuild"
			case serverVersion = "ServerVersion"
			case runtimes = "Runtimes"
			case defaultRuntime = "DefaultRuntime"
			case liveRestoreEnabled = "LiveRestoreEnabled"
			case isolation = "Isolation"
			case initBinary = "InitBinary"
			case containerdCommit = "ContainerdCommit"
			case runcCommit = "RuncCommit"
			case initCommit = "InitCommit"
			case securityOptions = "SecurityOptions"
			case productLicense = "ProductLicense"
			case defaultAddressPools = "DefaultAddressPools"
			case warnings = "Warnings"
			case cdiSpecDirs = "CDISpecDirs"
			case containerd = "Containerd"
		}
	}
}

public extension SystemInformationEndpoint.Response {
	// MARK: - Commit
	struct Commit: Codable {
		public init(id: String, expected: String) {
			self.id = id
			self.expected = expected
		}

		public let id, expected: String

		enum CodingKeys: String, CodingKey {
			case id = "ID"
			case expected = "Expected"
		}
	}
}

public extension SystemInformationEndpoint.Response {
	// MARK: - DefaultAddressPool
	struct DefaultAddressPool: Codable {
		public init(base: String, size: String) {
			self.base = base
			self.size = size
		}

		let base, size: String

		enum CodingKeys: String, CodingKey {
			case base = "Base"
			case size = "Size"
		}
	}
}

public extension SystemInformationEndpoint.Response {
	enum Isolation: String, Codable {
		case `default`, hyperv, process

		public init?(rawValue: String) {
			switch rawValue.lowercased() {
			case "default", "": self = .default
			case "hyperv": self = .hyperv
			case "process": self = .process
			default: return nil
			}
		}

		public init(from decoder: any Decoder) throws {
			let container = try decoder.singleValueContainer()
			let str = try container.decode(String.self)

			guard
				let new = Isolation(rawValue: str)
			else {
				throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid isolation value: \(str)"))
			}
			self = new
		}
	}
}

public extension SystemInformationEndpoint.Response {
	enum CgroupDriver: String, Codable {
		case cgroupfs, systemd, none
	}
}

public extension SystemInformationEndpoint.Response {
	// MARK: - Plugins
	struct Plugins: Codable {
		public init(volume: [String]? = nil, network: [String]? = nil, authorization: [String]? = nil, log: [String]? = nil) {
			self.volume = volume
			self.network = network
			self.authorization = authorization
			self.log = log
		}

		public let volume, network, authorization, log: [String]?

		enum CodingKeys: String, CodingKey {
			case volume = "Volume"
			case network = "Network"
			case authorization = "Authorization"
			case log = "Log"
		}
	}
}

public extension SystemInformationEndpoint.Response {
	// MARK: - RegistryConfig
	struct RegistryConfig: Codable {
		public init(
			allowNondistributableArtifactsCIDRs: [String]? = nil,
			allowNondistributableArtifactsHostnames: [String]? = nil,
			insecureRegistryCIDRs: [String],
			indexConfigs: [String: IndexConfig],
			mirrors: [String]? = nil
		) {
			self.allowNondistributableArtifactsCIDRs = allowNondistributableArtifactsCIDRs
			self.allowNondistributableArtifactsHostnames = allowNondistributableArtifactsHostnames
			self.insecureRegistryCIDRs = insecureRegistryCIDRs
			self.indexConfigs = indexConfigs
			self.mirrors = mirrors
		}

		public let allowNondistributableArtifactsCIDRs: [String]?
		public let allowNondistributableArtifactsHostnames: [String]?
		public let insecureRegistryCIDRs: [String]
		public let indexConfigs: [String: IndexConfig]
		public let mirrors: [String]?

		enum CodingKeys: String, CodingKey {
			case allowNondistributableArtifactsCIDRs = "AllowNondistributableArtifactsCIDRs"
			case allowNondistributableArtifactsHostnames = "AllowNondistributableArtifactsHostnames"
			case insecureRegistryCIDRs = "InsecureRegistryCIDRs"
			case indexConfigs = "IndexConfigs"
			case mirrors = "Mirrors"
		}

		// MARK: - IndexConfig
		public struct IndexConfig: Codable {
			public let name: String
			public let mirrors: [String]
			public let secure, official: Bool

			enum CodingKeys: String, CodingKey {
				case name = "Name"
				case mirrors = "Mirrors"
				case secure = "Secure"
				case official = "Official"
			}
		}
	}
}

public extension SystemInformationEndpoint.Response {
	// MARK: - Runtimes
	struct Runtimes: Codable {
		public init(runc: Runtimes.Runc? = nil, runcMaster: Runtimes.Runc? = nil, custom: Runtimes.Custom? = nil) {
			self.runc = runc
			self.runcMaster = runcMaster
			self.custom = custom
		}

		public let runc, runcMaster: Runc?
		public let custom: Custom?

		enum CodingKeys: String, CodingKey {
			case runc
			case runcMaster = "runc-master"
			case custom
		}

		// MARK: - Custom
		public struct Custom: Codable {
			public init(path: String, runtimeArgs: [String]) {
				self.path = path
				self.runtimeArgs = runtimeArgs
			}

			public let path: String
			public let runtimeArgs: [String]
		}

		// MARK: - Runc
		public struct Runc: Codable {
			public let path: String
		}
	}
}

public extension SystemInformationEndpoint.Response {
	struct ContainerdInfo: Codable {
		public init(address: String, namespaces: ContainerdInfo.Namespaces) {
			self.address = address
			self.namespaces = namespaces
		}

		public let address: String
		public let namespaces: Namespaces

		public struct Namespaces: Codable {
			public init(Containers: String, Plugins: String) {
				self.Containers = Containers
				self.Plugins = Plugins
			}

			public let Containers: String
			public let Plugins: String
		}
	}
}
