// MARK: - GenericResource
/// User-defined container resources can be either Integer resources (e.g, SSD=3) or String resources (e.g, GPU=UUID1).
public struct GenericResource: Codable {
	public var discreteResourceSpec: DiscreteSpec?
	public var namedResourceSpec: NamedSpec?
	
	enum CodingKeys: String, CodingKey {
		case discreteResourceSpec = "DiscreteResourceSpec"
		case namedResourceSpec = "NamedResourceSpec"
	}

	// MARK: - DiscreteResourceSpec
	public struct DiscreteSpec: Codable {
		public var kind: String
		public var value: Int

		enum CodingKeys: String, CodingKey {
			case kind = "Kind"
			case value = "Value"
		}
	}

	// MARK: - NamedResourceSpec
	public struct NamedSpec: Codable {
		public var kind, value: String

		enum CodingKeys: String, CodingKey {
			case kind = "Kind"
			case value = "Value"
		}
	}
}
