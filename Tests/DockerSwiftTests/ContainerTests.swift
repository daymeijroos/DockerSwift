import XCTest
@testable import DockerSwift
import Logging

final class ContainerTests: XCTestCase {

	var client: DockerClient!

	override func setUp() async throws {
		client = DockerClient.testable()
		if (try? await client.images.get("nginx:latest")) == nil {
			_ = try await client.images.pull(byName: "nginx", tag: "latest")
		}
		if (try? await client.images.get("hello-world:latest")) == nil {
			_ = try await client.images.pull(byName: "hello-world", tag: "latest")
		}
	}

	override func tearDownWithError() throws {
		try client.syncShutdown()
	}


	func testAttach() async throws {
		let _ = try await client.images.pull(byName: "alpine", tag: "latest")
		let config = ContainerConfig(
			attachStdin: true,
			attachStdout: true,
			attachStderr: true,
			image: "alpine:latest",
			openStdin: true
		)
		let containerInfo = try await client.containers.create(config: config)
		let container = try await client.containers.get(containerInfo.id)
		let attach = try await client.containers.attach(container: container, stream: true, logs: true)
		do {
			Task {
				for try await output in attach.output {
					XCTAssert(output == "Linux\n", "Ensure command output is properly read")
				}
			}
			try await client.containers.start(container.id)

			try await Task.sleep(nanoseconds: 1_000_000_000)
			try await attach.send("uname")
			try await Task.sleep(nanoseconds: 1_000_000_000)
		} catch(let error) {
			print("\n••••• BOOM! \(error)")
			throw error
		}

		try await client.containers.remove(container.id, force: true)
	}

	func testCreateContainer() async throws {
		let cmd = ["/custom/command", "--option"]
		let config = ContainerConfig(
			// Override the default command of the Image
			command: cmd,
			// Add new environment variables
			environmentVars: ["HELLO=hi"],
			// Expose port 80
			exposedPorts: [.tcp(80)],
			// Set custon container labels
			image: "hello-world:latest",
			labels: ["label1": "value1", "label2": "value2"],
			hostConfig: .init(
				// Memory the container is allocated when starting
				memoryReservation: .mb(32),
				// Maximum memory the container can use
				memoryLimit: .mb(64),
				// Needs to be either disabled (-1) or be equal to, or greater than, `memoryLimit`
				memorySwap: .mb(64),
				// Let's publish the port we exposed in `config`
				portBindings: [.tcp(80): [.publishTo(hostIp: "0.0.0.0", hostPort: 8008)]]))

		let name = "81A5DB11-78E9-4B21-9943-23FB75818224"
		let containerInfo = try await client.containers.create(name: name, config: config)
		let container = try await client.containers.get(containerInfo.id)
		XCTAssert(container.name.trimmingPrefix("/") == name, "Ensure name is set")
		XCTAssert(container.config.command == cmd, "Ensure custom command is set")
		let exposedPorts = try XCTUnwrap(container.config.exposedPorts)
		XCTAssert(exposedPorts[0].port == 80, "Ensure Exposed Port was set and retrieved")

		let portBindings = try XCTUnwrap(container.hostConfig.portBindings)

		XCTAssert(portBindings[.tcp(80)] != nil, "Ensure Published Port was set and retrieved")
		XCTAssert(container.hostConfig.memoryLimit == .mb(64), "Ensure MemoryLimit is set")

		try await client.containers.remove(container.id)
	}

	func testUpdateContainers() async throws {
		let name = UUID.init().uuidString
		let config = ContainerConfig(image: "nginx:latest")
		let container = try await client.containers.create(name: name, config: config)
		try await client.containers.start(container.id)

		let newConfig = UpdateContainerEndpoint.Update(memoryLimit: 64 * 1024 * 1024, memorySwap: 64 * 1024 * 1024)
		try await client.containers.update(container.id, config: newConfig)
	}

	func testFailUpdateContainers() async throws {
		let newConfig = UpdateContainerEndpoint.Update(memoryLimit: 64 * 1024 * 1024, memorySwap: 64 * 1024 * 1024)
		let task = Task {
			try await client.containers.update("fail", config: newConfig)
		}

		let	result = await task.result

		XCTAssertThrowsError(try result.get())
	}

	func testListContainers() async throws {
		let containers = try await client.containers.list(all: true)
		XCTAssert(containers.count >= 1)
		XCTAssert(containers.first!.createdAt > Date.distantPast)
	}

	func testInspectContainer() async throws {
		let container = try await client.containers.create(imageID: "hello-world:latest")
		let inspectedContainer = try await client.containers.get(container.id)

		XCTAssertEqual(inspectedContainer.id, container.id)
		XCTAssertEqual(inspectedContainer.config.command, ["/hello"])
	}

	func testRetrievingLogsNoTty() async throws {
		var hasContent = false
		for try await line in try await client.containers.logs(containerID: "hello-podman-notty", containerIsTTY: false, timestamps: true) {
			XCTAssertNotNil(line.timestamp, "Ensure timestamp is parsed properly")
			XCTAssert(line.source == .stdout, "Ensure stdout is properly detected")
			hasContent = true

		}
		XCTAssertTrue(hasContent)
	}

	// Log entries parsing is quite different depending on whether the container has a TTY
	func testRetrievingLogsTty() async throws {
		var hasContent = false
		for try await line in try await client.containers.logs(containerID: "hello-podman-tty", containerIsTTY: true, timestamps: true) {
			XCTAssertNotNil(line.timestamp, "Ensure timestamp is parsed properly")
			XCTAssert(line.source == .stdout, "Ensure stdout is properly detected")
			hasContent = true
		}
		XCTAssertTrue(hasContent)
	}

	func testPruneContainers() async throws {
		let container = try await client.containers.create(imageID: "nginx:latest")

		try await client.containers.start(container.id)
		try await client.containers.stop(container.id)

		let pruned = try await client.containers.prune()
		XCTAssert(pruned.reclaimedSpace > 0)
		XCTAssert(pruned.containersIds.contains(container.id))
	}

	func testPauseUnpauseContainers() async throws {
		let imageInfo = try await client.images.pull(byName: "nginx", tag: "latest")
		let image = try await client.images.get(imageInfo.digest)
		let container = try await client.containers.create(imageID: image.id)
		try await client.containers.start(container.id)

		try await client.containers.pause(container.id)
		try await client.containers.unpause(container.id)
	}

	func testRenameContainer() async throws {
		let container = try await client.containers.create(imageID: "nginx:latest")
		try await client.containers.start(container.id)
		try await client.containers.rename(container.id, to: "renamed")
	}

	func testProcessesContainer() async throws {
		let container = try await client.containers.create(imageID: "nginx:latest")
		try await client.containers.start(container.id)

		let psInfo = try await client.containers.processes(container.id)
		XCTAssertGreaterThan(psInfo.processes.count, 0, "Ensure processes are parsed")
	}

//	func testStatsContainer() async throws {
//		let container = try await client.containers.create(imageID: "nginx:latest")
//		try await client.containers.start(container.id)
//		try await Task.sleep(nanoseconds: 1_000_000_000)
//		do {
//			for try await stats in try await client.containers.stats(container.id, stream: false, oneShot: true) {
//				XCTAssert(stats.pids.current > 0, "Ensure stats response can be parsed")
//			}
//		}
//		catch(let error) {
//			print("\n••• BOOM! \(error)")
//			throw error
//		}
//		try await client.containers.remove(container.id, force: true)
//	}

	func testWaitContainer() async throws {
		let containerInfo = try await client.containers.create(imageID: "hello-world:latest")

		try await client.containers.start(containerInfo.id)
		let statusCode = try await client.containers.wait(containerInfo.id)
		XCTAssert(statusCode == 0, "Ensure container exited properly")
	}
}
