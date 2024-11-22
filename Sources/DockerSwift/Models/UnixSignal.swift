import Foundation

// A Unix signal that can be specified to stop or kill a container.
public enum UnixSignal: String, Encodable {
	case hup = "SIGHUP"
	case int = "SIGINT"
	
	/// Terminates and generates a core dump.
	case quit = "SIGQUIT"
	
	/// Illegal Instruction
	case ill   = "SIGILL"
	case trap  = "SIGTRAP"
	case abort = "SIGABRT"
	case bus   = "SIGBUS"
	case fpe   = "SIGFPE"
	
	/// Kill signal. Immediately terminates the container without being forwarded to it.
	case kill  = "SIGKILL"
	
	case usr1  = "SIGUSR1"
	case segv  = "SIGSEGV"
	case usr2  = "SIGUSR2"
	case pipe  = "SIGPIPE"
	case alarm = "SIGALRM"
	
	/// Termination signal
	case term       = "SIGTERM"
	case stackFault = "SIGSTKFLT"
	case child      = "SIGCHLD"
	case cont       = "SIGCONT"
	case stop       = "SIGSTOP"
	case tstp       = "SIGTSTP"
	
	public var toInt: UInt8 {
		return switch self {
		case .hup : 1
		case .int : 2
		case .quit : 3
		case .ill : 4
		case .trap : 5
		case .abort : 6
		case .bus : 7
		case .fpe : 8
		case .kill : 9
		case .usr1  : 10
		case .segv  : 11
		case .usr2  : 12
		case .pipe  : 13
		case .alarm : 14
		case .term  : 15
		case .stackFault : 16
		case .child    : 17
		case .cont     : 18
		case .stop     : 19
		case .tstp     : 20
		}
	}
	
}

/// This normally shouldn't be needed as Docker is expected to return a Unix signal as a string value, but I need to use Podman and podman returns integer values.
extension UnixSignal: Decodable {
	public init(from decoder: Swift.Decoder) throws {
		let container = try decoder.singleValueContainer()
		let rawValue = try container.decode(String.self)

		if let enumValue = UnixSignal.init(rawValue: rawValue) {
			self = enumValue
		}
		else if let intValue = Int(rawValue) {
			self = switch intValue {
			case 1: .hup
			case 2: .int
			case 3: .quit
			case 4: .ill
			case 5: .trap
			case 6: .abort
			case 7: .bus
			case 8: .fpe
			case 9: .kill
			case 10: .usr1
			case 11: .segv
			case 12: .usr2
			case 13: .pipe
			case 14: .alarm
			case 15: .term
			case 16: .stackFault
			case 17: .child
			case 18: .cont
			case 19: .stop
			case 20: .tstp
				
			default:
				throw DecodingError.dataCorruptedError(in: container, debugDescription: "is not a valid Unix signal integer")
			}
		}
		else {
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "is not a valid Unix signal integer or SIGXXXX value")
		}
	}
}
