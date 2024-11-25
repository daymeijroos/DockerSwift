import Foundation
import NIO

extension DockerClient {
	
	/// Get system information
	/// - Throws: Errors that can occur when executing the request.
	/// - Returns: Returns the `SystemInformation`.
	public func info() async throws -> SystemInformationEndpoint.Response {
		return try await run(SystemInformationEndpoint())
	}
	
	/// Endpoint you can use to test if the Docker server is accessible.
	public func ping() async throws {
		let ping = try await run(PingEndpoint())
		guard ping == "OK" else {
			throw DockerError.unknownResponse(ping)
		}
	}
	
	/// Get the version of the Docker runtime.
	/// - Throws: Errors that can occur when executing the request.
	/// - Returns: Returns the `DockerVersion`.
	public func version() async throws -> VersionEndpoint.Response {
		return try await run(VersionEndpoint())
	}
	
	/// Get data usage information.
	/// - Throws: Errors that can occur when executing the request.
	/// - Returns: Returns the `DataUsageInformation`.
	public func dataUsage() async throws -> DiskUsageInformationEndpoint.Response {
		return try await run(DiskUsageInformationEndpoint())
	}
	
	/// Stream real-time events from the Docker server.
	/// - Parameters:
	///   - since: Show events created since this timestamp, then stream new events.
	///   - until: Show events created until this timestamp then stop streaming.
	public func events(since: Date? = nil, until: Date? = nil) async throws -> AsyncThrowingStream<GetEventsEndpoint.Response, Error> {
		let endpoint = GetEventsEndpoint(since: since, until: until)
		return try await run(endpoint, timeout: .hours(12), hasLengthHeader: false, separators: [UInt8(ascii: "\n")])
	}
}
