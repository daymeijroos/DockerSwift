import XCTest
@testable import DockerSwift
import Logging

final class NetworkTests: XCTestCase {

	var client: DockerClient!

	override func setUp() {
		client = DockerClient.testable()
	}

	override func tearDownWithError() throws {
		try client.syncShutdown()
	}

	func testNetworkInpsect() async throws {
		let network = try await client.networks.get("7e77192f93582449e5806dc32639808ae078e0d5f38cc4636f1d7b9057e8c6e1")
		XCTAssertEqual(network.ipam.config.first?.gateway, "192.168.2.1")
	}

	func testListNetworks() async throws {
		let networkList = try await client.networks.list()

		XCTAssertGreaterThan(networkList.count, 0)
	}

	func testCreateNetwork() async throws {
		let name = "11E46E6F-BF6B-474B-A6E5-E08E1E48D454"
		let networkInfo = try await client.networks.create(
			spec: .init(
				name: name,
				ipam: .init(
					config: [.init(subnet: "192.168.2.0/24", gateway: "192.168.2.1")]
				)
			)
		)
		XCTAssertEqual(networkInfo.id, "7e77192f93582449e5806dc32639808ae078e0d5f38cc4636f1d7b9057e8c6e1")
	}

	func testPruneNetworks() async throws {
		let name = UUID().uuidString
		let networkInfo = try await client.networks.create(
			spec: .init(name: name)
		)
		let network = try await client.networks.get(networkInfo.id)
		let pruned = try await client.networks.prune()
		XCTAssert(pruned.contains(network.name), "Ensure created Network has been deleted")
	}

	func testConnectContainer() async throws {
		let name = UUID().uuidString
		let imageInfo = try await client.images.pull(byIdentifier: "nginx:latest")
		let image = try await client.images.get(imageInfo.digest)
		let networkInfo = try await client.networks.create(spec: .init(name: name))
		let network = try await client.networks.get(networkInfo.id)
		let containerInfo = try await client.containers.create(config: ContainerConfig(image: image.id, name: name))
		var container = try await client.containers.get(containerInfo.id)
		try await client.networks.connect(container: container.id, to: network.id)
		container = try await client.containers.get(container.id)
		XCTAssert(container.networkSettings.networks?[network.name] != nil, "Ensure Container is attached to Network")

		try await client.networks.disconnect(container: container.id, from: network.id)
		container = try await client.containers.get(container.id)
		XCTAssert(container.networkSettings.networks?[network.name] == nil, "Ensure Container is not attached to Network")

		try await client.containers.remove(container.id, force: true)
		try await client.networks.remove(network.id)
	}
}
