import NIOHTTP1

public struct DiskUsageInformationEndpoint: SimpleEndpoint {
    typealias Body = NoBody
    typealias Response = DataUsageInformation
    
    var method: HTTPMethod = .GET
    let path: String = "system/df"
}

extension DiskUsageInformationEndpoint: MockedResponseEndpoint {
    var responseData: [MockedResponseData] {
        [
            .string("""
                {"LayersSize":0,"Images":[{"Containers":8,"Created":1725624336,"Id":"511a44083d3a23416fadc62847c45d14c25cbace86e7a72b2b350436978a0450","Labels":{},"ParentId":"","RepoDigests":null,"RepoTags":["latest"],"SharedSize":0,"Size":9121900},{"Containers":0,"Created":1683046167,"Id":"ee301c921b8aadc002973b2e0c3da17d701dcd994b606769a7e6eaa100b81d44","Labels":{},"ParentId":"","RepoDigests":null,"RepoTags":["latest"],"SharedSize":0,"Size":24446}],"Containers":[],"Volumes":[],"BuildCache":[]}
                """)
        ]
    }
}
