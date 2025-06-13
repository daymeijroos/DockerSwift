import XCTest
@testable import Paddock
import Logging

final class PluginTests: XCTestCase {
	var client: PaddockClient!
	
	override func setUp() async throws {
		client = PaddockClient.testable()
	}
	
	override func tearDownWithError() throws {
		try client.syncShutdown()
	}
	
	func testListPlugins() async throws {
		let privileges = try await client.plugins.getPrivileges("vieux/sshfs:latest")
		try? await client.plugins.install(remote: "vieux/sshfs:latest", privileges: privileges)
		let plugins = try await client.plugins.list()
		XCTAssert(plugins.count > 0, "Ensure it returns at least one plugin")
		try await client.plugins.remove("vieux/sshfs:latest", force: true)
	}
	
	func testInspectPlugin() async throws {
		let privileges = try await client.plugins.getPrivileges("vieux/sshfs:latest")
		try? await client.plugins.install(remote: "vieux/sshfs:latest", privileges: privileges)
		try await client.plugins.enable("vieux/sshfs:latest")
		let plugin = try await client.plugins.get("vieux/sshfs:latest")
		try await client.plugins.remove("vieux/sshfs:latest", force: true)
	}
}
