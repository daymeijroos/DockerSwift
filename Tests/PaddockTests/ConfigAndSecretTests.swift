import XCTest
@testable import Paddock
import Logging

final class ConfigAndSecretTests: XCTestCase {

	var client: PaddockClient!

	override func setUp() async throws {
		client = PaddockClient.testable()
	}

	override func tearDownWithError() throws {
		try client.syncShutdown()
	}

	func testListConfigs() async throws {
		// TODO: improve and check the actual content
		let _ = try await client.configs.list()
	}

	func testCreateConfig() async throws {
		let name = UUID().uuidString
		let configData = "test config value 💥".data(using: .utf8)!
		let configInfo = try await client.configs.create(
			spec: .init(
				name: name,
				data: configData
			)
		)
		let config = try await client.configs.get(configInfo.id)
		XCTAssert(config.id != "", "Ensure ID is parsed")
		XCTAssert(config.spec.name == name, "Ensure name is set")
		XCTAssert(config.spec.data == configData, "Ensure Config data is correct")

		try await client.configs.remove(config.id)
	}

	func testCreateSecret() async throws {
		let name = UUID().uuidString
		let secretData = "test secret value".data(using: .utf8)!
		let secretInfo = try await client.secrets.create(
			spec: .init(
				name: name,
				data: secretData
			)
		)
		let secret = try await client.secrets.get(secretInfo.id)
		XCTAssert(secret.id != "", "Ensure ID is parsed")
		XCTAssert(secret.spec.name == name, "Ensure name is set")

		try await client.secrets.remove(secret.id)
	}
}
