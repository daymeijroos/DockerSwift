// MARK: - SwarmTLSInfo
public struct SwarmTLSInfo: Codable {
	public init(trustRoot: String, certIssuerSubject: String, certIssuerPublicKey: String) {
		self.trustRoot = trustRoot
		self.certIssuerSubject = certIssuerSubject
		self.certIssuerPublicKey = certIssuerPublicKey
	}
	
	public let trustRoot, certIssuerSubject, certIssuerPublicKey: String
	
	enum CodingKeys: String, CodingKey {
		case trustRoot = "TrustRoot"
		case certIssuerSubject = "CertIssuerSubject"
		case certIssuerPublicKey = "CertIssuerPublicKey"
	}
}
