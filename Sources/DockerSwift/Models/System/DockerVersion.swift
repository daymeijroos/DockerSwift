import Foundation
import BetterCodable

public struct DockerVersion: Codable {
    public init(platform: DockerPlatform, components: [DockerVersionComponent], version: String, apiVersion: String, minAPIVersion: String, gitCommit: String, goVersion: String, os: OsType, arch: Architecture, kernelVersion: String? = nil, buildTime: Date, experimental: Bool? = nil) {
        self.platform = platform
        self.components = components
        self.version = version
        self.apiVersion = apiVersion
        self.minAPIVersion = minAPIVersion
        self.gitCommit = gitCommit
        self.goVersion = goVersion
        self.os = os
        self.arch = arch
        self.kernelVersion = kernelVersion
        self.buildTime = buildTime
        self.experimental = experimental
    }
    
    
    public let platform: DockerPlatform
    
    /// Information about system components
    public let components: [DockerVersionComponent]
    
    /// The version of the daemon
    public let version: String
    
    /// The default (and highest) API version that is supported by the daemon
    public let apiVersion: String
    
    /// The minimum API version that is supported by the daemon
    public let minAPIVersion: String
    
    /// The Git commit of the source code that was used to build the daemon
    public let gitCommit: String
    
    /// The version Go used to compile the daemon, and the version of the Go runtime in use.
    public let goVersion: String
    
    /// The operating system that the daemon is running on ("linux" or "windows")
    public let os: OsType
    
    /// The CPU  architecture that the daemon is running on
    public let arch: Architecture
    
    /// The kernel version (uname -r) that the daemon is running on.
    public let kernelVersion: String?
    
    /// The date and time that the daemon was compiled.
	@DateValue<WeirdDockerStrategy>
    private(set) public var buildTime: Date
    
    /// Indicates if the daemon is started with experimental features enabled.
    /// This field is omitted when empty / false.
    public let experimental: Bool?
    
    enum CodingKeys: String, CodingKey {
        case platform = "Platform"
        case components = "Components"
        case version = "Version"
        case apiVersion = "ApiVersion"
        case minAPIVersion = "MinAPIVersion"
        case gitCommit = "GitCommit"
        case goVersion = "GoVersion"
        case os = "Os"
        case arch = "Arch"
        case kernelVersion = "KernelVersion"
        case buildTime = "BuildTime"
        case experimental = "Experimental"
    }
}

// MARK: - Component
public struct DockerVersionComponent: Codable {
    public init(name: String, version: String, details: DockerVersionComponentDetails? = nil) {
        self.name = name
        self.version = version
        self.details = details
    }
    
    public let name, version: String
    public let details: DockerVersionComponentDetails?
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case version = "Version"
        case details = "Details"
    }
}

// MARK: - Details
public struct DockerVersionComponentDetails: Codable {
    public let apiVersion, arch: String?
    
    // This is a boolean, but encoded as a String
    public let experimental: String?
    
    // This is a Date but is not encoded using the format used elsewhere in the Docker API.
    public let buildTime: String?
    
    public let gitCommit: String?
    public let goVersion, kernelVersion, minAPIVersion: String?
    
    public let os: OsType
    
    enum CodingKeys: String, CodingKey {
        case apiVersion = "ApiVersion"
        case arch = "Arch"
        case buildTime = "BuildTime"
        case experimental = "Experimental"
        case gitCommit = "GitCommit"
        case goVersion = "GoVersion"
        case kernelVersion = "KernelVersion"
        case minAPIVersion = "MinAPIVersion"
        case os = "Os"
    }
}

// MARK: - Platform
public struct DockerPlatform: Codable {
    public init(name: String) {
        self.name = name
    }
    
    public let name: String
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
    }
}
