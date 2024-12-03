import XCTest
@testable import Paddock
import Logging

final class VolumeTests: XCTestCase {
	
	var client: DockerClient!
	
	override func setUp() {
		client = DockerClient.forTesting()
	}
	
	override func tearDownWithError() throws {
		try client.syncShutdown()
	}

	func testCreateVolume() async throws {
		let name = "TestVolumeStorage"
		let volSpec = CreateVolumeEndpoint.Body(name: name)

		let volume = try await client.volumes.create(spec: volSpec)

		XCTAssertEqual(volume.name, name)
	}

	func testRemoveVolume() async throws {
		try await client.volumes.remove("TestVolumeStorage")
	}

	func testListVolumes() async throws {
		let volumes = try await client.volumes.list()
		XCTAssertGreaterThan(volumes.volumes.count, 0)
	}
	
	func testPruneVolumes() async throws {
		let pruned = try await client.volumes.prune()
		XCTAssertGreaterThan(pruned.volumesDeleted.count, 0)
	}
}
