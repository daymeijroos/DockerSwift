@testable import Paddock

extension GetLogsEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		switch id {
		case "hello-podman-tty":
			return [
				.string(#"2024-11-26T03:30:28-06:00 !... Hello Podman World ...!"#),
				.string(#"2024-11-26T03:30:28-06:00"#),
				.string(#"2024-11-26T03:30:28-06:00          .--"--."#),
				.string(#"2024-11-26T03:30:28-06:00        / -     - \"#),
				.string(#"2024-11-26T03:30:28-06:00       / (O)   (O) \"#),
				.string(#"2024-11-26T03:30:28-06:00    ~~~| -=(,Y,)=- |"#),
				.string(#"2024-11-26T03:30:28-06:00     .---. /`  \   |~~"#),
				.string(#"2024-11-26T03:30:28-06:00  ~/  o  o \~~~~.----. ~~"#),
				.string(#"2024-11-26T03:30:28-06:00   | =(X)= |~  / (O (O) \"#),
				.string(#"2024-11-26T03:30:28-06:00    ~~~~~~~  ~| =(Y_)=-  |"#),
				.string(#"2024-11-26T03:30:28-06:00   ~~~~    ~~~|   U      |~~"#),
				.string(#"2024-11-26T03:30:28-06:00"#),
				.string(#"2024-11-26T03:30:28-06:00 Project:   https://github.com/containers/podman"#),
				.string(#"2024-11-26T03:30:28-06:00 Website:   https://podman.io"#),
				.string(#"2024-11-26T03:30:28-06:00 Desktop:   https://podman-desktop.io"#),
				.string(#"2024-11-26T03:30:28-06:00 Documents: https://docs.podman.io"#),
				.string(#"2024-11-26T03:30:28-06:00 YouTube:   https://youtube.com/@Podman"#),
				.string(#"2024-11-26T03:30:28-06:00 X/Twitter: @Podman_io"#),
				.string(#"2024-11-26T03:30:28-06:00 Mastodon:  @Podman_io@fosstodon.org"#),
			]
		case "hello-podman-notty":
			return [
				.base64EncodedString("AQAAAAAAADcyMDI0LTExLTI2VDAzOjQwOjM3LTA2OjAwICEuLi4gSGVsbG8gUG9kbWFuIFdvcmxkIC4uLiEK"),
				.base64EncodedString("AQAAAAAAABsyMDI0LTExLTI2VDAzOjQwOjM3LTA2OjAwIAo="),
				.base64EncodedString("AQAAAAAAADYyMDI0LTExLTI2VDAzOjQwOjM3LTA2OjAwICAgICAgICAgIC4tLSItLS4gICAgICAgICAgIAo="),
				.base64EncodedString("AQAAAAAAADYyMDI0LTExLTI2VDAzOjQwOjM3LTA2OjAwICAgICAgICAvIC0gICAgIC0gXCAgICAgICAgIAo="),
				.base64EncodedString("AQAAAAAAADYyMDI0LTExLTI2VDAzOjQwOjM3LTA2OjAwICAgICAgIC8gKE8pICAgKE8pIFwgICAgICAgIAo="),
				.base64EncodedString("AQAAAAAAADcyMDI0LTExLTI2VDAzOjQwOjM3LTA2OjAwICAgIH5+fnwgLT0oLFksKT0tIHwgICAgICAgICAK"),
				.base64EncodedString("AQAAAAAAADYyMDI0LTExLTI2VDAzOjQwOjM3LTA2OjAwICAgICAuLS0tLiAvYCAgXCAgIHx+fiAgICAgIAo="),
				.base64EncodedString("AQAAAAAAADYyMDI0LTExLTI2VDAzOjQwOjM3LTA2OjAwICB+LyAgbyAgbyBcfn5+fi4tLS0tLiB+fiAgIAo="),
				.base64EncodedString("AQAAAAAAADYyMDI0LTExLTI2VDAzOjQwOjM3LTA2OjAwICAgfCA9KFgpPSB8fiAgLyAoTyAoTykgXCAgIAo="),
				.base64EncodedString("AQAAAAAAADcyMDI0LTExLTI2VDAzOjQwOjM3LTA2OjAwICAgIH5+fn5+fn4gIH58ID0oWV8pPS0gIHwgICAK"),
				.base64EncodedString("AQAAAAAAADcyMDI0LTExLTI2VDAzOjQwOjM3LTA2OjAwICAgfn5+fiAgICB+fn58ICAgVSAgICAgIHx+fiAK"),
				.base64EncodedString("AQAAAAAAABsyMDI0LTExLTI2VDAzOjQwOjM3LTA2OjAwIAo="),
				.base64EncodedString("AQAAAAAAAEoyMDI0LTExLTI2VDAzOjQwOjM3LTA2OjAwIFByb2plY3Q6ICAgaHR0cHM6Ly9naXRodWIuY29tL2NvbnRhaW5lcnMvcG9kbWFuCg=="),
				.base64EncodedString("AQAAAAAAADcyMDI0LTExLTI2VDAzOjQwOjM3LTA2OjAwIFdlYnNpdGU6ICAgaHR0cHM6Ly9wb2RtYW4uaW8K"),
				.base64EncodedString("AQAAAAAAAD8yMDI0LTExLTI2VDAzOjQwOjM3LTA2OjAwIERlc2t0b3A6ICAgaHR0cHM6Ly9wb2RtYW4tZGVza3RvcC5pbwo="),
				.base64EncodedString("AQAAAAAAADwyMDI0LTExLTI2VDAzOjQwOjM3LTA2OjAwIERvY3VtZW50czogaHR0cHM6Ly9kb2NzLnBvZG1hbi5pbwo="),
				.base64EncodedString("AQAAAAAAAEEyMDI0LTExLTI2VDAzOjQwOjM3LTA2OjAwIFlvdVR1YmU6ICAgaHR0cHM6Ly95b3V0dWJlLmNvbS9AUG9kbWFuCg=="),
				.base64EncodedString("AQAAAAAAADAyMDI0LTExLTI2VDAzOjQwOjM3LTA2OjAwIFgvVHdpdHRlcjogQFBvZG1hbl9pbwo="),
				.base64EncodedString("AQAAAAAAAD4yMDI0LTExLTI2VDAzOjQwOjM3LTA2OjAwIE1hc3RvZG9uOiAgQFBvZG1hbl9pb0Bmb3NzdG9kb24ub3JnCg=="),
			]
		default:
			logger.error("⚠️ Requested logs for container not found: \(id).")
			return []
		}
	}
}
