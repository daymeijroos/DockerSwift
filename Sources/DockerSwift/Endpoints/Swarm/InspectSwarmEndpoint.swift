import NIOHTTP1
import Foundation

public struct InspectSwarmEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = SwarmResponse
	let method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] { [] }

	var path: String {
		"swarm"
	}
	
	public struct SwarmResponseVersion: Codable {
		public let Index: UInt64
	}
	
	public struct SwarmJoinTokens: Codable {
		public let manager: String
		public let worker: String
		
		enum CodingKeys: String, CodingKey {
			case manager = "Manager"
			case worker = "Worker"
		}
	}
	
	public struct SwarmTLSInfo: Codable {
		public let CertIssuerPublicKey: String
		public let CertIssuerSubject: String
		public let TrustRoot: String
	}
	
	public struct SwarmResponse: Codable {
		public init(id: String, createdAt: String, updatedAt: String, dataPathPort: UInt16, defaultAddrPool: [String], joinTokens: InspectSwarmEndpoint.SwarmJoinTokens, rootRotationInProgress: Bool, spec: SwarmSpec, subnetSize: UInt8, tlsInfo: InspectSwarmEndpoint.SwarmTLSInfo, version: InspectSwarmEndpoint.SwarmResponseVersion) {
			self.id = id
			self.createdAt = createdAt
			self.updatedAt = updatedAt
			self.dataPathPort = dataPathPort
			self.defaultAddrPool = defaultAddrPool
			self.joinTokens = joinTokens
			self.rootRotationInProgress = rootRotationInProgress
			self.spec = spec
			self.subnetSize = subnetSize
			self.tlsInfo = tlsInfo
			self.version = version
		}
		
		public var id: String
		
		public var createdAt: String
		public var updatedAt: String
		
		/// DataPathPort specifies the data path port number for data traffic. Acceptable port range is 1024 to 49151.
		/// If no port is set or is set to 0, the default port (4789) is used.
		public var dataPathPort: UInt16
		
		public var defaultAddrPool: [String]
		
		public var joinTokens: SwarmJoinTokens
		
		/// Whether there is currently a root CA rotation in progress for the swarm
		public var rootRotationInProgress: Bool
		
		public var spec: SwarmSpec
		
		/// SubnetSize specifies the subnet size of the networks created from the default subnet pool.
		public var subnetSize: UInt8
		
		public var tlsInfo: SwarmTLSInfo
		
		public var version: SwarmResponseVersion
		
		enum CodingKeys: String, CodingKey {
			case id = "ID"
			case createdAt = "CreatedAt"
			case updatedAt = "UpdatedAt"
			case dataPathPort = "DataPathPort"
			case defaultAddrPool = "DefaultAddrPool"
			case joinTokens = "JoinTokens"
			case rootRotationInProgress = "RootRotationInProgress"
			case spec = "Spec"
			case subnetSize = "SubnetSize"
			case tlsInfo = "TLSInfo"
			case version = "Version"
		}
	}
}
