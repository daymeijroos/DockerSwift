import NIOHTTP1
import Foundation

public struct CreateVolumeEndpoint: SimpleEndpoint {
	var body: Body?
	
	typealias Response = Volume
	typealias Body = VolumeSpec
	let method: HTTPMethod = .POST
	var queryArugments: [URLQueryItem] { [] }

	init(spec: VolumeSpec) {
		self.body = spec
	}
	
	var path: String {
		"volumes/create"
	}
}

public extension CreateVolumeEndpoint {
	/// Structure to specify the configuration for creating a Volume.
	struct VolumeSpec: Codable {
		public init(name: String? = nil, driver: String = "local", driverOptions: [String : String] = [:], labels: [String : String] = [:]) {
			self.name = name
			self.driver = driver
			self.driverOptions = driverOptions
			self.labels = labels
		}

		/// The new volume's name. If not specified, Docker generates a name.
		public var name: String?

		/// Name of the volume driver to use.
		public var driver: String = "local"

		/// A mapping of driver options and values. These options are passed directly to the driver and are driver specific.
		public var driverOptions: [String:String] = [:]

		/// User-defined key/value metadata.
		public var labels: [String:String] = [:]

		enum CodingKeys: String, CodingKey {
			case name = "Name"
			case driver = "Driver"
			case driverOptions = "DriverOpts"
			case labels = "Labels"
		}
	}
}
