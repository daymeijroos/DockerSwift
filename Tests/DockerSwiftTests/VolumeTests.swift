import XCTest
@testable import DockerSwift
import Logging

final class VolumeTests: XCTestCase {
	
	var client: DockerClient!
	
	override func setUp() {
		client = DockerClient.testable()
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
		let name = UUID().uuidString
		let volume = try await client.volumes.create(
			spec: .init(name: name)
		)
		let pruned = try await client.volumes.prune()
		XCTAssert(pruned.volumesDeleted.contains(volume.name), "Ensure created Volume got deleted")
	}
}
