@testable import DockerSwift

extension ListContainersEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.string(#"[{"Id":"f9b36abb2ddb840d01971746c29718f97d85aed18a0aaf0dc6a3bc22f3a0fe4f","Names":["/condescending_goodall"],"Image":"docker.io/library/hello-world:latest","ImageID":"sha256:ee301c921b8aadc002973b2e0c3da17d701dcd994b606769a7e6eaa100b81d44","Command":"/hello","Created":1732356626,"Ports":[],"Labels":{},"State":"created","Status":"Created","NetworkSettings":{"Networks":{"podman":{"IPAMConfig":null,"Links":null,"Aliases":["f9b36abb2ddb"],"MacAddress":"","DriverOpts":null,"NetworkID":"podman","EndpointID":"","Gateway":"","IPAddress":"","IPPrefixLen":0,"IPv6Gateway":"","GlobalIPv6Address":"","GlobalIPv6PrefixLen":0,"DNSNames":null}}},"Mounts":[],"Name":"","Config":null,"NetworkingConfig":null,"Platform":null,"DefaultReadOnlyNonRecursive":false}]"#)
		]
	}
}


