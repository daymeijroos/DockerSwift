import NIOHTTP1

struct CreateVolumeEndpoint: SimpleEndpoint {
	var body: Body?
	
	typealias Response = Volume
	typealias Body = VolumeSpec
	var method: HTTPMethod = .POST
		
	init(spec: VolumeSpec) {
		self.body = spec
	}
	
	var path: String {
		"volumes/create"
	}
}
