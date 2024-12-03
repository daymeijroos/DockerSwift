import XCTest
@testable import Paddock
import Logging

final class SystemTests: XCTestCase {
	var client: PaddockClient!
	
	override func setUp() {
		client = PaddockClient.forTesting()
	}
	
	override func tearDownWithError() throws {
		try client.syncShutdown()
	}
	
	func testDockerVersion() async throws {
		let version = try await client.version()
		XCTAssert(version.version != "", "Ensure Version field is set")
		XCTAssert(version.buildTime > Date.distantPast, "Ensure BuildTime field is parsed")
	}
	
	func testDataUsage() async throws {
		let _ = try await client.images.pull(byName: "hello-world", tag: "latest")
		let dataUsage = try await client.dataUsage()
		XCTAssert(dataUsage.images.count > 0, "Ensure images field is parsed")
	}
	
	func testEvents() async throws {
		let _ = try await client.images.pull(byName: "hello-world", tag: "latest")
		let name = "81A5DB11-78E9-4B21-9943-23FB75818224"
		async let events = try client.events(since: Date())
		try await Task.sleep(nanoseconds: 2_000_000_000)
		let _ = try await client.containers.create(config: ContainerConfig(image: "hello-world:latest", name: name))
		addTeardownBlock { [client] in
			try await client?.containers.remove(name, force: true, removeAnonymousVolumes: true)
		}
		
		for try await event in try await events {
			if event.action == .create && event.type == .container {
				XCTAssert(event.actor.attributes?["name"] == name, "Ensure create event for this container is emitted")
				break
			}
		}
	}
	
	func testSystemInfo() async throws {
		let info = try await client.info()
		XCTAssert(info.id != "", "Ensure id is set")
	}
	
	func testPing() async throws {
		try await client.ping()
	}
}
