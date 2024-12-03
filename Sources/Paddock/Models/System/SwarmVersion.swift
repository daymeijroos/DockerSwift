// MARK: - SwarmVersion
public struct SwarmVersion: Codable {
	public init(index: UInt64) {
		self.index = index
	}
	
	public let index: UInt64
	
	enum CodingKeys: String, CodingKey {
		case index = "Index"
	}
}
