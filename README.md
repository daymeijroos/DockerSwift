# Paddock (Podman/Docker Client)
[![Language](https://img.shields.io/badge/Swift-5.9-brightgreen.svg)](http://swift.org)
[![Docker Engine API](https://img.shields.io/badge/Docker%20Engine%20API-%20%201.41-blue)](https://docs.docker.com/engine/api/v1.41/)
[![Platforms](https://img.shields.io/badge/platform-linux--64%20%7C%20osx--64-blue)]()

This is a low-level Docker/Podman Client written in Swift. It very closely follows the Docker API. It is forked from [DockerSwift](https://github.com/m-barthelemy/DockerSwift.git)
with the goal of adding mocked tests with addditional support and focus for [Podman](https://podman.io).

## Docker API version support
This client library aims at implementing the Docker API version 1.41 (https://docs.docker.com/engine/api/v1.41).
This means that it will work with Docker >= 20.10.


## Current implementation status

| Section                     | Operation                 | Support | Tests | Notes                                                         |
| --------------------------- | ------------------------- | ------- | ----- | ------------------------------------------------------------- |
| Client connection           | Local Unix socket         | ✅       | ❌     |                                                               |
|                             | HTTP                      | ✅       | ❌     |                                                               |
|                             | HTTPS                     | ✅       | ❌     |                                                               |
|                             | Mocks                     |         | ✅     |                                                               |
|                             |                           |         |       |                                                               |
| Docker daemon & System info | Ping                      | ✅       | ✅     |                                                               |
|                             | Info                      | ✅       | ✅     |                                                               |
|                             | Version                   | ✅       | ✅     |                                                               |
|                             | Events                    | ✅       | ✅     |                                                               |
|                             | Get data usage info       | ✅       | ✅     |                                                               |
|                             |                           |         |       |                                                               |
| Containers                  | List                      | ✅       | ✅     |                                                               |
|                             | Inspect                   | ✅       | ✅     |                                                               |
|                             | Create                    | ✅       | ✅     |                                                               |
|                             | Update                    | ✅       | ✅     |                                                               |
|                             | Rename                    | ✅       | ✅     |                                                               |
|                             | Start/Stop/Kill           | ✅       | ✅❌    | no kill test                                                  |
|                             | Pause/Unpause             | ✅       | ✅     |                                                               |
|                             | Get logs                  | ✅       | ✅     |                                                               |
|                             | Get stats                 | 🟡       | ❌     | implementation deprecated, but code exists. needs overhauling |
|                             | Get processes (top)       | ✅       | ✅     |                                                               |
|                             | Delete                    | ✅       | ✅     |                                                               |
|                             | Prune                     | ✅       | ✅     |                                                               |
|                             | Wait                      | ✅       | ✅     |                                                               |
|                             | Filesystem changes        | ✅       | ❌     |                                                               |
|                             | Attach                    | ✅       | ✅     |                                                               |
|                             | Exec                      | ❌       | ❌     | unlikely <sup>2</sup>                                         |
|                             | Resize TTY                | ❌       | ❌     |                                                               |
|                             |                           |         |       |                                                               |
| Images                      | List                      | ✅       | ✅     |                                                               |
|                             | Inspect                   | ✅       | ✅     |                                                               |
|                             | History                   | ✅       | ✅     |                                                               |
|                             | Pull                      | ✅       | ✅     | basic support                                                 |
|                             | Build                     | ✅       | ✅     | basic support                                                 |
|                             | Tag                       | ✅       | ✅     |                                                               |
|                             | Push                      | ✅       | ✅     |                                                               |
|                             | Create (container commit) | ✅       | ✅     |                                                               |
|                             | Delete                    | ✅       | ✅     |                                                               |
|                             | Prune                     | ✅       | ✅     |                                                               |
|                             |                           |         |       |                                                               |
| Networks                    | List                      | ✅       | ✅     |                                                               |
|                             | Inspect                   | ✅       | ✅     |                                                               |
|                             | Create                    | ✅       | ✅     |                                                               |
|                             | Delete                    | ✅       | ✅     |                                                               |
|                             | Prune                     | ✅       | ✅     |                                                               |
|                             | (Dis)connect container    | ✅       | ✅     |                                                               |
|                             |                           |         |       |                                                               |
| Volumes                     | List                      | ✅       | ✅     |                                                               |
|                             | Inspect                   | ✅       | ❌     |                                                               |
|                             | Create                    | ✅       | ✅     |                                                               |
|                             | Delete                    | ✅       | ✅     |                                                               |
|                             | Prune                     | ✅       | ✅     |                                                               |
|                             |                           |         |       |                                                               |
| Secrets                     | List                      | ✅       | 🟡     | Legacy tests exist, but have not been updated or mocked       |
|                             | Inspect                   | ✅       | 🟡     | Legacy tests exist, but have not been updated or mocked       |
|                             | Create                    | ✅       | 🟡     | Legacy tests exist, but have not been updated or mocked       |
|                             | Update                    | ✅       | 🟡     | Legacy tests exist, but have not been updated or mocked       |
|                             | Delete                    | ✅       | 🟡     | Legacy tests exist, but have not been updated or mocked       |
|                             |                           |         |       |                                                               |
| Plugins                     | List                      | ✅       | 🟡     | Legacy tests exist, but have not been updated or mocked       |
|                             | Inspect                   | ✅       | 🟡     | Legacy tests exist, but have not been updated or mocked       |
|                             | Get Privileges            | ✅       | 🟡     | Legacy tests exist, but have not been updated or mocked       |
|                             | Install                   | ✅       | 🟡     | Legacy tests exist, but have not been updated or mocked       |
|                             | Remove                    | ✅       | 🟡     | Legacy tests exist, but have not been updated or mocked       |
|                             | Enable/disable            | ✅       | 🟡     | Legacy tests exist, but have not been updated or mocked       |
|                             | Upgrade                   | ✅       | 🟡     | untested                                                      |
|                             | Configure                 | ✅       | 🟡     | untested                                                      |
|                             | Create                    | ❌       |       | TBD                                                           |
|                             | Push                      | ❌       |       | TBD                                                           |
|                             |                           |         |       |                                                               |
| Registries                  | Login                     | ✅       |       | basic support                                                 |
|                             |                           |         |       |                                                               |
| Docker error responses mgmt |                           | 🟡       |       |                                                               |



✅ : done or _mostly_ done

🟡 : work in progress, partially implemented, might not work

❌ : not implemented/supported at the moment.

Note: various Docker endpoints such as list or prune support *filters*. These are currently not implemented.

<sup>2</sup> Docker exec is using an unconventional protocol that requires raw access to the TCP socket. Significant work needed in order to support it (https://github.com/swift-server/async-http-client/issues/353).


## Installation
### Package.swift 
```Swift
import PackageDescription

let package = Package(
    dependencies: [
        .package(url: "https://github.com/mredig/Paddock.git", .branch("main")),
    ],
    targets: [
        .target(name: "App", dependencies: [
            ...
            .product(name: "Paddock", package: "Paddock")
        ]),
    ...
    ]
)
```

### Xcode Project
To add Paddock to your existing Xcode project, select File -> Swift Packages -> Add Package Dependancy. 
Enter `https://github.com/mredig/Paddock.git` for the URL.


## Usage Examples

#### *Note that these examples might be out of date as they are from prior to the fork*

### Connect to a Docker daemon

Local socket (defaults to `/var/run/docker.sock`):
```swift
import Paddock

let docker = DockerClient()
defer { try! docker.syncShutdown() }
```

Remote daemon over HTTP:
```swift
import Paddock

let docker = DockerClient(daemonURL: URL(string: "http://127.0.0.1:2375")!)
defer { try! docker.syncShutdown() }
```

Remote daemon over HTTPS, using a client certificate for authentication:
```swift
import Paddock

var tlsConfig = TLSConfiguration.makeClientConfiguration()
tlsConfig.privateKey = NIOSSLPrivateKeySource.file("client-key.pem")
tlsConfig.certificateChain.append(NIOSSLCertificateSource.file("client-certificate.pem"))
tlsConfig.additionalTrustRoots.append(.file("docker-daemon-ca.pem"))
tlsConfig.certificateVerification = .noHostnameVerification

let docker = DockerClient(
    daemonURL: .init(string: "https://your.docker.daemon:2376")!,
    tlsConfig: tlsConfig
)
defer { try! docker.syncShutdown() }
```

### Docker system info
<details>
  <summary>Get detailed information about the Docker daemon</summary>
  
  ```swift
  let info = try await docker.info()
  print("• Docker daemon info: \(info)")
  ```
</details>

<details>
  <summary>Get versions information about the Docker daemon</summary>
  
  ```swift
  let version = try await docker.version()
  print("• Docker API version: \(version.apiVersion)")
  ```
</details>

<details>
  <summary>Listen for Docker daemon events</summary>
  
  We start by listening for docker events, then we create a container:
  ```swift
  async let events = try await docker.events()
  
  let container = try await docker.containers.create(
      name: "hello",
      spec: .init(
          config: .init(image: "hello-world:latest"),
          hostConfig: .init()
      )
  )
  ```
  
  Now, we should get an event whose `action` is "create" and whose `type` is "container".
  ```swift
  for try await event in try await events {
      print("\n••• event: \(event)")
  }
  ```
</details>

 
### Containers
<details>
  <summary>List containers</summary>
  
  Add `all: true` to also return stopped containers.
  ```swift
  let containers = try await docker.containers.list()
  ```
</details>

<details>
  <summary>Get a container details</summary>
  
  ```swift
  let container = try await docker.containers.get("nameOrId")
  ```
</details>

<details>
  <summary>Create a container</summary>
  
  > Note: you will also need to start it for the container to actually run.
  
  The simplest way of creating a new container is to only specify the image to run:
  ```swift
  let spec = ContainerSpec(
      config: .init(image: "hello-world:latest")
  )
  let container = try await docker.containers.create(name: "test", spec: spec)
  ```
  
  Docker allows customizing many parameters:
  ```swift
  let spec = ContainerSpec(
      config: .init(
          // Override the default command of the Image
          command: ["/custom/command", "--option"],
          // Add new environment variables
          environmentVars: ["HELLO=hi"],
          // Expose port 80
          exposedPorts: [.tcp(80)],
          image: "nginx:latest",
          // Set custom container labels
          labels: ["label1": "value1", "label2": "value2"]
      ),
      hostConfig: .init(
          // Memory the container is allocated when starting
          memoryReservation: .mb(64),
          // Maximum memory the container can use
          memoryLimit: .mb(128),
          // Needs to be either disabled (-1) or be equal to, or greater than, `memoryLimit`
          memorySwap: .mb(128),
          // Let's publish the port we exposed in `config`
          portBindings: [.tcp(80): [.publishTo(hostIp: "0.0.0.0", hostPort: 8000)]]
      )
  )
  let container = try await docker.containers.create(name: "nginx-test", spec: spec)
  ```
</details>

<details>
  <summary>Update a container</summary>
  
  Let's update the memory limits for an existing container:
  ```swift
  let newConfig = ContainerUpdate(memoryLimit: .mb(64), memorySwap: .mb(64))
  try await docker.containers.update("nameOrId", spec: newConfig)
  ```
</details>

<details>
  <summary>Start a container</summary>
  
  ```swift
  try await docker.containers.start("nameOrId")
  ```
</details>

<details>
  <summary>Stop a container</summary>
  
  ```swift
  try await docker.containers.stop("nameOrId")
  ```
</details>

<details>
  <summary>Rename a container</summary>
  
  ```swift
  try await docker.containers.rename("nameOrId", to: "hahi")
  ```
</details>

<details>
  <summary>Delete a container</summary>
  
  If the container is running, deletion can be forced by passing `force: true` 
  ```swift
  try await docker.containers.remove("nameOrId")
  ```
</details>

<details>
  <summary>Get container logs</summary>
  
  > Logs are streamed progressively in an asynchronous way.
  
  Get all logs:
  ```swift
  let container = try await docker.containers.get("nameOrId")
        
  for try await line in try await docker.containers.logs(container: container, timestamps: true) {
      print(line.message + "\n")
  }
  ```
  
  Wait for future log messages:
  ```swift
  let container = try await docker.containers.get("nameOrId")
        
  for try await line in try await docker.containers.logs(container: container, follow: true) {
      print(line.message + "\n")
  }
  ```
  
  Only the last 100 messages:
  ```swift
  let container = try await docker.containers.get("nameOrId")
        
  for try await line in try await docker.containers.logs(container: container, tail: 100) {
      print(line.message + "\n")
  }
  ```
</details>

<details>
  <summary>Attach to a container</summary>
  
  Let's create a container that defaults to running a shell, and attach to it:
  ```swift
  let _ = try await docker.images.pull(byIdentifier: "alpine:latest")
  let spec = ContainerSpec(
      config: .init(
          attachStdin: true,
          attachStdout: true,
          attachStderr: true,
          image: "alpine:latest",
          openStdin: true
      )
  )
  let container = try await docker.containers.create(spec: spec)
  let attach = try await docker.containers.attach(container: container, stream: true, logs: true)
  
  // Let's display any output from the container
  Task {
      for try await output in attach.output {
          print("• \(output)")
      }
  }
  
  // We need to be sure that the container is really running before being able to send commands to it.
  try await docker.containers.start(container.id)
  try await Task.sleep(for: .seconds(1))
  
  // Now let's send the command; the response will be printed to the screen.
  try await attach.send("uname")
  ```
</details>
  

### Images
<details>
  <summary>List the Docker images</summary>
  
  ```swift
  let images = try await docker.images.list()
  ```
</details>

<details>
  <summary>Get an image details</summary>
  
  ```swift
  let image = try await docker.images.get("nameOrId")
  ```
</details>

<details>
  <summary>Pull an image</summary>
  
  Pull an image from a public repository:
  ```swift
  let image = try await docker.images.pull(byIdentifier: "hello-world:latest")
  ```

  Pull an image from a registry that requires authentication:
  ```swift
  var credentials = RegistryAuth(username: "myUsername", password: "....")
  try await docker.registries.login(credentials: &credentials)
  let image = try await docker.images.pull(byIdentifier: "my-private-image:latest", credentials: credentials)
  ```
  > NOTE: `RegistryAuth` also accepts a `serverAddress` parameter in order to use a custom registry.
  
  > Creating images from a remote URL or from the standard input is currently not supported.
</details>

<details>
  <summary>Push an image</summary>

  Supposing that the Docker daemon has an image named "my-private-image:latest":
  ```swift
  var credentials = RegistryAuth(username: "myUsername", password: "....")
  try await docker.registries.login(credentials: &credentials)
  try await docker.images.push("my-private-image:latest", credentials: credentials)
  ```
  > NOTE: `RegistryAuth` also accepts a `serverAddress` parameter in order to use a custom registry.
</details>

<details>
  <summary>Build an image</summary>
  
  > The current implementation of this library is very bare-bones.
  > The Docker build context, containing the Dockerfile and any other resources required during the build, must be passed as a TAR archive.
  
  Supposing we already have a TAR archive of the build context:
  ```swift
  let tar = FileManager.default.contents(atPath: "/tmp/docker-build.tar")
  let buffer = ByteBuffer.init(data: tar)
  let buildOutput = try await docker.images.build(
      config: .init(dockerfile: "./Dockerfile", repoTags: ["build:test"]),
      context: buffer
  )
  // The built Image ID is returned towards the end of the build output
  var imageId: String!
  for try await item in buildOutput {
      if item.aux != nil {
          imageId = item.aux!.id
      }
      else {
        print("\n• Build output: \(item.stream)")
      }
  }
  print("\n• Image ID: \(imageId)")
  ```
  
  You can use external libraries to create TAR archives of your build context.
  Example with [Tarscape](https://github.com/kayembi/Tarscape) (only available on macOS):
  ```swift
  import Tarscape
  
  let tarContextPath = "/tmp/docker-build.tar"
  try FileManager.default.createTar(
      at: URL(fileURLWithPath: tarContextPath),
      from: URL(string: "file:///path/to/your/context/folder")!
  )
  ```
</details>


### Networks
<details>
  <summary>List networks</summary>
  
  ```swift
  let networks = try await docker.networks.list()
  ```
</details>

<details>
  <summary>Get a network details</summary>
  
  ```swift
  let network = try await docker.networks.get("nameOrId")
  ```
</details>

<details>
  <summary>Create a network</summary>
  
  Create a new network without any custom options:
  ```swift
  let network = try await docker.networks.create(
    spec: .init(name: "my-network")
  )
  ```
  
  Create a new network with custom IPs range:
  ```swift
  let network = try await docker.networks.create(
      spec: .init(
          name: "my-network",
          ipam: .init(
              config: [.init(subnet: "192.168.2.0/24", gateway: "192.168.2.1")]
          )
      )
  )
  ```
</details>

<details>
  <summary>Delete a network</summary>
  
  ```swift
  try await docker.networks.remove("nameOrId")
  ```
</details>

<details>
  <summary>Connect an existing Container to a Network</summary>
  
  ```swift
  let network = try await docker.networks.create(spec: .init(name: "myNetwork"))
  var container = try await docker.containers.create(
      name: "myContainer",
      spec: .init(config: .init(image: image.id))
  )
  
  try await docker.networks.connect(container: container.id, to: network.id)
  ```
</details>


### Volumes
<details>
  <summary>List volumes</summary>
  
  ```swift
  let volumes = try await docker.volumes.list()
  ```
</details>

<details>
  <summary>Get a volume details</summary>
  
  ```swift
  let volume = try await docker.volumes.get("nameOrId")
  ```
</details>

<details>
  <summary>Create a volume</summary>
  
  ```swift
  let volume = try await docker.volumes.create(
    spec: .init(name: "myVolume", labels: ["myLabel": "value"])
  )
  ```
</details>

<details>
  <summary>Delete a volume</summary>
  
  ```swift
  try await docker.volumes.remove("nameOrId")
  ```
</details>


### Secrets
> This requires a Docker daemon with Swarm mode enabled.
> 
> Note: The API for managing Docker Configs is very similar to the Secrets API and the below examples also apply to them.

<details>
  <summary>List secrets</summary>
  
  ```swift
  let secrets = try await docker.secrets.list()
  ```
</details>

<details>
  <summary>Get a secret details</summary>
  
  > Note: The Docker API doesn't return secret data/values.
  
  ```swift
  let secret = try await docker.secrets.get("nameOrId")
  ```
</details>

<details>
  <summary>Create a secret</summary>
  
  Create a Secret containing a `String` value:
  ```swift
  let secret = try await docker.secrets.create(
    spec: .init(name: "mySecret", value: "test secret value 💥")
  )
  ```
  
  You can also pass a `Data` value to be stored as a Secret:
  ```swift
  let data: Data = ...
  let secret = try await docker.secrets.create(
    spec: .init(name: "mySecret", data: data)
  )
  ```
</details>

<details>
  <summary>Update a secret</summary>
  
  > Currently, only the `labels` field can be updated (Docker limitation).
  
  ```swift
  try await docker.secrets.update("nameOrId", labels: ["myKey": "myValue"])
  ```
</details>

<details>
  <summary>Delete a secret</summary>
  
  ```swift
  try await docker.secrets.remove("nameOrId")
  ```
</details>


### Plugins
<details>
  <summary>List installed plugins</summary>
  
  ```swift
  let plugins = try await docker.plugins.list()
  ```
</details>

<details>
  <summary>Install a plugin</summary>
  
  > Note: the `install()` method can be passed a `credentials` parameter containing credentials for a private registry.
  > See "Pull an image" for more information.
  ```swift
  // First, we fetch the privileges required by the plugin:
  let privileges = try await docker.plugins.getPrivileges("vieux/sshfs:latest")
  
  // Now, we can install it
  try await docker.plugins.install(remote: "vieux/sshfs:latest", privileges: privileges)
  
  // finally, we need to enable it before using it
  try await docker.plugins.enable("vieux/sshfs:latest")
  ```
</details>


## Why "Paddock"?
In short, ***Pod***man + ***Dock***er = "Poddock", which sounds similar to the actual word "Paddock". Now I just need to get a logo that evokes the imagery of horses frolicking in a meadow.

## Credits
This is a fork of the foundational work by [m-barthelemy](https://github.com/m-barthelemy/DockerSwift.git), which itself is also a fork of [alexsteinerde's](https://github.com/alexsteinerde/docker-client-swift) work.

## License
This project is released under the MIT license. See [LICENSE](LICENSE) for details.


## Contribute
You can contribute to this project by submitting a detailed issue or by forking this project and sending a pull request. Contributions of any kind are very welcome :)

To run tests, make sure you have docker or podman installed and, if the default path for the socket 
(`/var/run/docker.sock`) is not correct, to set the env var `DOCKER_HOST` while running tests. On Linux, you may need 
to activate the docker service. On Ubuntu, for example, run `systemctl start docker` and `systemctl enable docker`, 
which should then populate the default socket location. 
