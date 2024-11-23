import Foundation

/// Information to log into a Docker registry.
public struct RegistryAuth: Codable {
	
	public var username: String
	
	public var email: String? = nil
	
	/// The registry password.
	/// Note: when using the Docker Hub with 2FA enabled, you must create a Personal Access Token and use its value as the password.
	public var password: String
	
	/// The URL of the registry. Defaults to the Docker Hub.
	public var serverAddress: URL = URL(string: "https://index.docker.io/v1/")!
	
	/// The token obtained after logging into the registry
	@available(*, deprecated)
	internal(set) public var token: String? = nil

	public init(username: String, email: String? = nil, password: String, serverAddress: URL = URL(string: "https://index.docker.io/v1/")!) {
		self.username = username
		self.email = email
		self.password = password
		self.serverAddress = serverAddress
	}

	func entoken() -> Token {
		.init(auth: self)
	}

	public struct Token: RawRepresentable, Codable, Sendable, Hashable {
		public let rawValue: String

		public init(rawValue: String) {
			self.rawValue = rawValue
		}

		init(auth: RegistryAuth) {
			let serverAddress = auth
				.serverAddress
				.absoluteString
				.trimmingPrefix(auth.serverAddress.scheme.map { $0 + "://" } ?? "")
			let creds = [
				"username": auth.username,
				"password": auth.password,
				"serveraddress": String(serverAddress),
			]
			let json = try! JSONEncoder().encode(creds)
			let b64 = json.base64EncodedString()
			self.init(rawValue: b64)
		}
	}
}
