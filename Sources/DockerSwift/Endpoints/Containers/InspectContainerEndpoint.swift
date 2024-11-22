import Foundation
import NIOHTTP1

struct InspectContainerEndpoint: SimpleEndpoint {
	typealias Body = NoBody
	typealias Response = Container
	var method: HTTPMethod = .GET
	
	let nameOrId: String
	
	init(nameOrId: String) {
		self.nameOrId = nameOrId
	}
	
	var path: String {
		"containers/\(nameOrId)/json"
	}
}

extension InspectContainerEndpoint: MockedResponseEndpoint {
	var responseData: [MockedResponseData] {
		[
			.string("""
				{"Id":"ce25040926ba103e72dd4070db9a07c4510291a3a3475b0cb175dd06dddfbc93","Created":"2024-11-22T08:59:12.398708593Z","Path":"/hello","Args":["/hello"],"State":{"Status":"created","Running":false,"Paused":false,"Restarting":false,"OOMKilled":false,"Dead":false,"Pid":0,"ExitCode":0,"Error":"","StartedAt":"0001-01-01T00:00:00Z","FinishedAt":"0001-01-01T00:00:00Z"},"Image":"sha256:ee301c921b8aadc002973b2e0c3da17d701dcd994b606769a7e6eaa100b81d44","ResolvConfPath":"","HostnamePath":"","HostsPath":"","LogPath":"","Name":"/81A5DB11-78E9-4B21-9943-23FB75818224","RestartCount":0,"Driver":"overlay","Platform":"linux","MountLabel":"system_u:object_r:container_file_t:s0:c147,c152","ProcessLabel":"system_u:system_r:container_t:s0:c147,c152","AppArmorProfile":"","ExecIDs":[],"HostConfig":{"Binds":[],"ContainerIDFile":"","LogConfig":{"Type":"journald","Config":null},"NetworkMode":"bridge","PortBindings":{},"RestartPolicy":{"Name":"no","MaximumRetryCount":0},"AutoRemove":false,"VolumeDriver":"","VolumesFrom":null,"ConsoleSize":[0,0],"CapAdd":[],"CapDrop":[],"CgroupnsMode":"","Dns":[],"DnsOptions":[],"DnsSearch":[],"ExtraHosts":[],"GroupAdd":[],"IpcMode":"shareable","Cgroup":"","Links":null,"OomScoreAdj":0,"PidMode":"private","Privileged":false,"PublishAllPorts":false,"ReadonlyRootfs":false,"SecurityOpt":[],"UTSMode":"private","UsernsMode":"","ShmSize":65536000,"Runtime":"oci","Isolation":"","CpuShares":0,"Memory":0,"NanoCpus":0,"CgroupParent":"user.slice","BlkioWeight":0,"BlkioWeightDevice":null,"BlkioDeviceReadBps":null,"BlkioDeviceWriteBps":null,"BlkioDeviceReadIOps":null,"BlkioDeviceWriteIOps":null,"CpuPeriod":0,"CpuQuota":0,"CpuRealtimePeriod":0,"CpuRealtimeRuntime":0,"CpusetCpus":"","CpusetMems":"","Devices":[],"DeviceCgroupRules":null,"DeviceRequests":null,"MemoryReservation":0,"MemorySwap":0,"MemorySwappiness":0,"OomKillDisable":false,"PidsLimit":0,"Ulimits":[],"CpuCount":0,"CpuPercent":0,"IOMaximumIOps":0,"IOMaximumBandwidth":0,"MaskedPaths":null,"ReadonlyPaths":null},"GraphDriver":{"Data":{"LowerDir":"/var/home/core/.local/share/containers/storage/overlay/12660636fe55438cc3ae7424da7ac56e845cdb52493ff9cf949c47a7f57f8b43/diff","UpperDir":"/var/home/core/.local/share/containers/storage/overlay/ed5b652c53438edede43a21342fcb0fbe8756d8989cc3faced8f687b80732904/diff","WorkDir":"/var/home/core/.local/share/containers/storage/overlay/ed5b652c53438edede43a21342fcb0fbe8756d8989cc3faced8f687b80732904/work"},"Name":"overlay"},"SizeRootFs":0,"Mounts":[],"Config":{"Hostname":"ce25040926ba","Domainname":"","User":"","AttachStdin":false,"AttachStdout":false,"AttachStderr":false,"Tty":false,"OpenStdin":false,"StdinOnce":false,"Env":["container=podman","PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"],"Cmd":["/hello"],"Image":"docker.io/library/hello-world:latest","Volumes":null,"WorkingDir":"/","Entrypoint":[],"OnBuild":null,"Labels":{},"StopSignal":"15","StopTimeout":10},"NetworkSettings":{"Bridge":"","SandboxID":"","SandboxKey":"","Ports":{},"HairpinMode":false,"LinkLocalIPv6Address":"","LinkLocalIPv6PrefixLen":0,"SecondaryIPAddresses":null,"SecondaryIPv6Addresses":null,"EndpointID":"","Gateway":"","GlobalIPv6Address":"","GlobalIPv6PrefixLen":0,"IPAddress":"","IPPrefixLen":0,"IPv6Gateway":"","MacAddress":"","Networks":{"podman":{"IPAMConfig":null,"Links":null,"Aliases":["ce25040926ba"],"MacAddress":"","DriverOpts":null,"NetworkID":"podman","EndpointID":"","Gateway":"","IPAddress":"","IPPrefixLen":0,"IPv6Gateway":"","GlobalIPv6Address":"","GlobalIPv6PrefixLen":0,"DNSNames":null}}}}
				""")
		]
	}
}
