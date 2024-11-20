import Foundation

public enum DockerEnvironment {
	public static var dockerApiVersion: String? {
		ProcessInfo.processInfo.environment["DOCKER_API_VERSION"]
	}

	public static var dockerCertPath: String? {
		ProcessInfo.processInfo.environment["DOCKER_CERT_PATH"]
	}

	public static var dockerConfig: String? {
		ProcessInfo.processInfo.environment["DOCKER_CONFIG"]
	}

	public static var dockerContentTrustServer: String? {
		ProcessInfo.processInfo.environment["DOCKER_CONTENT_TRUST_SERVER"]
	}

	public static var dockerContentTrust: String? {
		ProcessInfo.processInfo.environment["DOCKER_CONTENT_TRUST"]
	}

	public static var dockerContext: String? {
		ProcessInfo.processInfo.environment["DOCKER_CONTEXT"]
	}

	public static var dockerCustomHeaders: String? {
		ProcessInfo.processInfo.environment["DOCKER_CUSTOM_HEADERS"]
	}

	public static var dockerDefaultPlatform: String? {
		ProcessInfo.processInfo.environment["DOCKER_DEFAULT_PLATFORM"]
	}

	public static var dockerHideLegacyCommands: String? {
		ProcessInfo.processInfo.environment["DOCKER_HIDE_LEGACY_COMMANDS"]
	}

	public static var dockerHost: String {
		if let envProvided = ProcessInfo.processInfo.environment["DOCKER_HOST"] {
			String(envProvided.trimmingPrefix("unix://"))
		} else {
			"/var/run/docker.sock"
		}
	}

	public static var dockerTLS: String? {
		ProcessInfo.processInfo.environment["DOCKER_TLS"]
	}

	public static var dockerTlsVerify: String? {
		ProcessInfo.processInfo.environment["DOCKER_TLS_VERIFY"]
	}

	public static var buildkitProgress: String? {
		ProcessInfo.processInfo.environment["BUILDKIT_PROGRESS"]
	}
}
