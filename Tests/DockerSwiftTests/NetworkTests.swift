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
		let pruned = try await client.networks.prune()
		XCTAssertGreaterThan(pruned.networksDeleted.count, 0)
	}

	func testRemoveNetwork() async throws {
		let name = "11E46E6F-BF6B-474B-A6E5-E08E1E48D454"
		let network = try await client.networks.get(name)
		try await client.networks.remove(network.id)
	}

	func testConnectContainer() async throws {
		let network = try await client.networks.get("11E46E6F-BF6B-474B-A6E5-E08E1E48D454")

		let container = try await client.containers.get("ce25040926ba103e72dd4070db9a07c4510291a3a3475b0cb175dd06dddfbc93")

		try await client.networks.connect(container: container.id, to: network.id)
	}


	func testDisconnectContainer() async throws {
		let network = try await client.networks.get("11E46E6F-BF6B-474B-A6E5-E08E1E48D454")

		let container = try await client.containers.get("ce25040926ba103e72dd4070db9a07c4510291a3a3475b0cb175dd06dddfbc93")

		try await client.networks.disconnect(container: container.id, from: network.id)
	}
}
