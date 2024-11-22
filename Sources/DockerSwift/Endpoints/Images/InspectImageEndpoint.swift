import Foundation
import NIOHTTP1

struct InspectImagesEndpoint: SimpleEndpoint {
    typealias Body = NoBody
    typealias Response = Image
    var method: HTTPMethod = .GET
    
    let nameOrId: String
    
    init(nameOrId: String) {
        self.nameOrId = nameOrId
    }
    
    var path: String {
        "images/\(nameOrId)/json"
    }
}

extension InspectImagesEndpoint: MockedResponseEndpoint {
    var responseData: [MockedResponseData] {
        [
            .string("""
                {"Id":"sha256:ee301c921b8aadc002973b2e0c3da17d701dcd994b606769a7e6eaa100b81d44","RepoTags":["docker.io/library/hello-world:latest"],"RepoDigests":["docker.io/library/hello-world@sha256:2d4e459f4ecb5329407ae3e47cbc107a2fbace221354ca75960af4c047b3cb13","docker.io/library/hello-world@sha256:305243c734571da2d100c8c8b3c3167a098cab6049c9a5b066b6021a60fcb966"],"Parent":"","Comment":"buildkit.dockerfile.v0","Created":"2023-05-02T16:49:27Z","ContainerConfig":{"Hostname":"ee301c921b8","Domainname":"","User":"","AttachStdin":false,"AttachStdout":false,"AttachStderr":false,"Tty":false,"OpenStdin":false,"StdinOnce":false,"Env":null,"Cmd":null,"Image":"","Volumes":null,"WorkingDir":"","Entrypoint":null,"OnBuild":null,"Labels":null},"DockerVersion":"","Author":"","Config":{"Hostname":"","Domainname":"","User":"","AttachStdin":false,"AttachStdout":false,"AttachStderr":false,"Tty":false,"OpenStdin":false,"StdinOnce":false,"Env":["PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"],"Cmd":["/hello"],"Image":"","Volumes":null,"WorkingDir":"/","Entrypoint":null,"OnBuild":null,"Labels":null},"Architecture":"arm64","Os":"linux","Size":24446,"VirtualSize":24446,"GraphDriver":{"Data":{"UpperDir":"/var/home/core/.local/share/containers/storage/overlay/12660636fe55438cc3ae7424da7ac56e845cdb52493ff9cf949c47a7f57f8b43/diff","WorkDir":"/var/home/core/.local/share/containers/storage/overlay/12660636fe55438cc3ae7424da7ac56e845cdb52493ff9cf949c47a7f57f8b43/work"},"Name":"overlay"},"RootFS":{"Type":"layers","Layers":["sha256:12660636fe55438cc3ae7424da7ac56e845cdb52493ff9cf949c47a7f57f8b43"]},"Metadata":{"LastTagTime":"0001-01-01T00:00:00Z"},"Container":""}
                """)
        ]
    }
}
