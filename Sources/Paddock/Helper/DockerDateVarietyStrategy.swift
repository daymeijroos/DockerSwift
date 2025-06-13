import Foundation
import BetterCodable

/// Docker sometimes provides timestamps with fractional seconds and sometimes without.
/// Both are valid ISO8601 standards, but require different configurations.
public struct DockerDateVarietyStrategy: DateValueCodableStrategy {
	private static let isoFractionsFormatter: ISO8601DateFormatter = {
		let new = ISO8601DateFormatter()
		new.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
		return new
	}()

	private static let isoBasicFormatter = ISO8601DateFormatter()

	public static func decode(_ value: String) throws -> Date {
		if let date = isoBasicFormatter.date(from: value) {
			return date
		} else if let date = isoFractionsFormatter.date(from: value) {
			return date
		} else {
			throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid Date Format!"))
		}
	}
	
	public static func encode(_ date: Date) -> String {
		return isoFractionsFormatter.string(from: date)
	}
}
