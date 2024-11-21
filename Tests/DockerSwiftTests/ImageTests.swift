import XCTest
@testable import DockerSwift
import Logging
import NIO

final class ImageTests: XCTestCase {
    
    var client: DockerClient!
    
    override func setUp() async throws {
        client = DockerClient.testable()
        if (try? await client.images.get("nginx:latest")) == nil {
            _ = try await client.images.pull(byName: "nginx", tag: "latest")
        }
    }
    
    override func tearDownWithError() throws {
        try client.syncShutdown()
    }
    
    func testDeleteImage() async throws {
        try await client.images.remove("nginx:latest", force: true)
    }
    
    func testPullImage() async throws {
        let image = try await client.images.pull(byName: "nginx", tag: "latest")
        
        XCTAssertTrue(image.repoTags!.contains(where: { $0.contains("nginx:latest") }))
    }
    
    func testPushImage() async throws {
        guard let password = ProcessInfo.processInfo.environment["REGISTRY_PASSWORD"] else {
            fatalError("REGISTRY_PASSWORD is not set")
        }
        var credentials = RegistryAuth(username: "mbarthelemy", password: password)
        try await client.registries.login(credentials: &credentials)
        
        let tag = UUID().uuidString
        let image = try await client.images.get("nginx:latest")
        try await client.images.tag(image.id, repoName: "mbarthelemy/tests", tag: tag)
        
        try await client.images.push("mbarthelemy/tests", tag: tag, credentials: credentials)
    }
    
    func testListImage() async throws {
        let images = try await client.images.list()
        
        XCTAssert(images.count >= 1)
    }
    
    /*func testParsingRepositoryTagSuccessfull() {
        let rt = Image.RepositoryTag("hello-world:latest")
        
        XCTAssertEqual(rt?.repository, "hello-world")
        XCTAssertEqual(rt?.tag, "latest")
    }
    
    func testParsingRepositoryTagThreeComponents() {
        let rt = Image.RepositoryTag("hello-world:latest:anotherone")
        
        XCTAssertNil(rt)
    }
    
    func testParsingRepositoryTagOnlyRepo() {
        let rt = Image.RepositoryTag("hello-world")
        
        XCTAssertEqual(rt?.repository, "hello-world")
        XCTAssertNil(rt?.tag)
    }
    
    func testParsingRepositoryTagWithDigest() {
        let rt = Image.RepositoryTag("sha256:89b647c604b2a436fc3aa56ab1ec515c26b085ac0c15b0d105bc475be15738fb")
        
        XCTAssertNil(rt)
    }*/
    
    func testInspectImage() async throws {
        let image = try await client.images.get("nginx:latest")
        let repoTags = try XCTUnwrap(image.repoTags)
        XCTAssertTrue(repoTags.contains(where: { $0.contains("nginx:latest") }), "Ensure repoTags exists")
    }
    
    func testImageHistory() async throws {
        let image = try await client.images.get("nginx:latest")
        let history = try await client.images.history(image.id)
        XCTAssert(history.count > 0 && history.first!.id.starts(with: "sha256"))
    }
    
    func testPruneImages() async throws {
        let image = try await client.images.get("nginx:latest")
        let cleanID = String(image.id.trimmingPrefix("sha256:"))
        let pruned = try await client.images.prune(all: true)
        XCTAssertTrue(pruned.imageIds.contains(cleanID))
        XCTAssertGreaterThan(pruned.reclaimedSpace, 0)

        let images = try await client.images.list()
        XCTAssertFalse(images.map(\.id).contains(image.id))
    }
    
    func testBuild() async throws {
        let tarPath = Bundle.module.url(forResource: "docker-context", withExtension: "tar", subdirectory: "Assets")!

        let tar = try Data(contentsOf: tarPath)
        let buffer = ByteBuffer.init(data: tar)
        var imageID: String!
        do {
            let buildOutput = try await client.images.build(
                config: .init(
                    repoTags: ["build:test"],
                    buildArgs: ["TEST": "test"],
                    labels: ["test": "value"]
                ),
                context: buffer)

            for try await item in buildOutput {
                guard let auxID = item.aux?.id else { continue }
                imageID = auxID
            }
            XCTAssertNotNil(imageID, "Ensure built Image ID is returned")
            addTeardownBlock { [client, imageID] in
                try await client?.images.remove(imageID!)
            }
        } catch {
            print("\n•••• BOOM! \(error)")
            throw error
        }
        let image = try await client.images.get(imageID)
        let repoTags = try XCTUnwrap(image.repoTags)
        XCTAssertTrue(repoTags.contains(where: { $0.contains("build:test") }), "Ensure repo and tag are set")
        let labels = try XCTUnwrap(image.config.labels)
        XCTAssertEqual(labels["test"], "value", "Ensure labels are set")
    }
    
    func testCommit() async throws {
        let container = try await client.containers.create(
            name: nil,
            spec: ContainerSpec(
                config: ContainerConfig(image: "nginx:latest", tty: true),
                hostConfig: .init())
        )
        try await client.containers.start(container.id)
        let image = try await client.images.createFromContainer(container.id, repo: "test-commit", tag: "latest")
        addTeardownBlock { [client] in
            try await client?.images.remove(image.id)
        }
        let repoTags = try XCTUnwrap(image.repoTags)
        XCTAssertTrue(repoTags.contains(where: { $0.contains("test-commit:latest") }), "Ensure image has custom repo and tag")
    }
}
