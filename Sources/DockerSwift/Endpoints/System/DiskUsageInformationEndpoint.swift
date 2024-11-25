import NIOHTTP1
import Foundation

public struct DiskUsageInformationEndpoint: SimpleEndpoint {
	typealias Body = NoBody

	let method: HTTPMethod = .GET
	var queryArugments: [URLQueryItem] { [] }
	let path: String = "system/df"
}

public extension DiskUsageInformationEndpoint {
	/// Details about the Docker daemon data usage
	struct Response: Codable {
		public let layersSize: UInt64
		public let images: [ImageSummary]
		public let containers: [ContainerSummary]
		public let volumes: [Volume]
		//public let buildCache: [BuildCache]?
		public let builderSize: UInt64?

		enum CodingKeys: String, CodingKey {
			case layersSize = "LayersSize"
			case images = "Images"
			case containers = "Containers"
			case volumes = "Volumes"
			//case buildCache = "BuildCache"
			case builderSize = "BuilderSize"
		}
	}
}
