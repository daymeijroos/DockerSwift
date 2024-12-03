import Foundation
import Logging

extension DockerClient {
	
	/// APIs related to Docker registries.
	public var registries: RegistriesAPI {
		.init(client: self)
	}
	
	public struct RegistriesAPI {
		fileprivate var client: DockerClient
		
		/// Log into a docker registry (gets a token)
		/// - Parameters:
		///   - credentials: configuration as a `RegistryAuth`.
		/// - Throws: Errors that can occur when executing the request.
		public func login(credentials: inout RegistryAuth, logger: Logger) async throws -> RegistryAuth.Token {
			let response = try await client.run(RegistryLoginEndpoint(credentials: credentials))
			logger.debug("\(response.status)")

			let encodedToken = credentials.entoken()
			return encodedToken
		}
	}
}
