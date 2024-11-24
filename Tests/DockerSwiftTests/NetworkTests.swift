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
		let networks = try await client.networks.list()
		let network = try await client.networks.get(networks.first!.id)
		XCTAssert(network.createdAt > Date.distantPast, "ensure createdAt field is parsed")
	}

	func testListNetworks() async throws {
		// TODO: improve and check the actual content
		let _ = try await client.networks.list()
	}

	func testCreateNetwork() async throws {
		let name = UUID().uuidString
		let network = try await client.networks.create(
			spec: .init(
				name: name,
				ipam: .init(
					config: [.init(subnet: "192.168.2.0/24", gateway: "192.168.2.1")]
				)
			)
		)
		XCTAssert(network.id != "", "Ensure Network ID is parsed")
		XCTAssert(network.name == name, "Ensure Network name is set")
		XCTAssert(network.ipam.config[0].subnet == "192.168.2.0/24", "Ensure custom subnet is set")

		try await client.networks.remove(network.id)
	}

	func testPruneNetworks() async throws {
		let name = UUID().uuidString
		let network = try await client.networks.create(
			spec: .init(name: name)
		)
		let pruned = try await client.networks.prune()
		XCTAssert(pruned.contains(network.name), "Ensure created Network has been deleted")
	}

	func testConnectContainer() async throws {
		let name = UUID().uuidString
		let imageInfo = try await client.images.pull(byIdentifier: "nginx:latest")
		let image = try await client.images.get(imageInfo.digest)
		let network = try await client.networks.create(spec: .init(name: name))
		var container = try await client.containers.create(spec: ContainerConfig(image: image.id, name: name))
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
