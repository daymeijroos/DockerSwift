@testable import Paddock

extension InspectNetworkEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		switch nameOrId {
		case "11E46E6F-BF6B-474B-A6E5-E08E1E48D454", "7e77192f93582449e5806dc32639808ae078e0d5f38cc4636f1d7b9057e8c6e1":
			return [
				.string(#"{"Name":"11E46E6F-BF6B-474B-A6E5-E08E1E48D454","Id":"7e77192f93582449e5806dc32639808ae078e0d5f38cc4636f1d7b9057e8c6e1","Created":"2024-12-03T02:58:12.400429667-06:00","Scope":"local","Driver":"bridge","EnableIPv6":false,"IPAM":{"Driver":"default","Options":{"driver":"host-local"},"Config":[{"Subnet":"192.168.2.0/24","Gateway":"192.168.2.1"}]},"Internal":false,"Attachable":false,"Ingress":false,"ConfigFrom":{"Network":""},"ConfigOnly":false,"Containers":{},"Options":{},"Labels":{}}"#)
			]
		default:
			logger.error("⚠️ Requested mock network not found: \(nameOrId).")
			return []
		}
	}
}
