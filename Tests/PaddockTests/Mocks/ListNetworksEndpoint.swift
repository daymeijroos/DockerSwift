@testable import Paddock

extension ListNetworksEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.string(#"[{"Name":"11E46E6F-BF6B-474B-A6E5-E08E1E48D454","Id":"7e77192f93582449e5806dc32639808ae078e0d5f38cc4636f1d7b9057e8c6e1","Created":"2024-12-03T02:58:12.400429667-06:00","Scope":"local","Driver":"bridge","EnableIPv6":false,"IPAM":{"Driver":"default","Options":{"driver":"host-local"},"Config":[{"Subnet":"192.168.2.0/24","Gateway":"192.168.2.1"}]},"Internal":false,"Attachable":false,"Ingress":false,"ConfigFrom":{"Network":""},"ConfigOnly":false,"Containers":{},"Options":{},"Labels":{}},{"Name":"bridge","Id":"2f259bab93aaaaa2542ba43ef33eb990d0999ee1b9924b557b7be53c0b7a1bb9","Created":"2024-12-03T02:58:54.218595941-06:00","Scope":"local","Driver":"bridge","EnableIPv6":false,"IPAM":{"Driver":"default","Options":{"driver":"host-local"},"Config":[{"Subnet":"10.88.0.0/16","Gateway":"10.88.0.1"}]},"Internal":false,"Attachable":false,"Ingress":false,"ConfigFrom":{"Network":""},"ConfigOnly":false,"Containers":{},"Options":{},"Labels":{}}]"#)
		]
	}
}


