import Foundation
import BetterCodable

/// Basic Container information returned when listing containers
public struct ContainerSummary: Codable {
	public let id: String
	
	/// The names that this container has been given
	public let names: [String]
	
	/// The name of the image used when creating this container
	public let image: String
	
	/// The ID of the image that this container was created from
	public let imageId: String
	
	/// Command to run when starting the container
	public let command: String
	
	/// When the container was created
	@DateValue<TimestampStrategy>
	private(set)public var createdAt: Date
	
	/// The ports exposed by this container
	public let ports: [ExposedPort]
	
	public let labels: [String: String]
	
	/// The state of this container (e.g. `exited`)
	public let state: Container.State.State
	
	/// Additional human-readable status of this container (e.g. "Exit 0")
	public let status: String
	
	// TODO: HostConfig
	
	/// List of mount points in use by a container.
	public let mounts: [Container.ContainerMountPoint]
	
	/// A summary of the container's network settings
	public let networkSettings: NetworkSettings
	
	public struct ExposedPort: Codable, Hashable {
		public let ip: String?
		public let privatePort: UInt16
		public let publicPort: UInt16?
		public let type: ExposedPortSpec.PortProtocol
		
		enum CodingKeys: String, CodingKey {
			case ip = "IP"
			case privatePort = "PrivatePort"
			case publicPort = "PublicPort"
			case type = "Type"
		}
	}
	
	public struct NetworkSettings: Codable {
		public let networks: [String: IPAM.IPAMConfig]?

		enum CodingKeys: String, CodingKey {
			case networks = "Networks"
		}
	}
	
	enum CodingKeys: String, CodingKey {
		case id = "Id"
		case names = "Names"
		case image = "Image"
		case imageId = "ImageID"
		case command = "Command"
		case createdAt = "Created"
		case ports = "Ports"
		case labels = "Labels"
		case mounts = "Mounts"
		case state = "State"
		case networkSettings = "NetworkSettings"
		case status = "Status"
	}
}

extension ContainerSummary {
	public init(from container: Container) throws {
		let ports = container
			.hostConfig
			.portBindings?
			.map { binding in
				let internalPort = binding.key.port
				let prot = binding.key.protocol
				let array = binding.value ?? []
				return array.map { info in
					ExposedPort(
						ip: info.hostIp,
						privatePort: internalPort,
						publicPort: info.hostPort,
						type: prot)
				}
			}
			.flatMap { $0 }


		self.init(
			id: container.id,
			names: [container.name],
			image: container.config.image,
			imageId: container.image,
			command: container.config.command?.joined(separator: " ") ?? "",
			createdAt: container.createdAt,
			ports: ports ?? [],
			labels: container.config.labels ?? [:],
			state: container.state.status,
			status: container.state.status.rawValue,
			mounts: container.mounts,
			networkSettings: .init(networks: container.networkSettings.networks))
	}
}
