@testable import Paddock

extension ListImagesEndpoint: MockedResponseEndpoint {
	public var responseData: [MockedResponseData] {
		[
			.string(#"[{"Id":"sha256:511a44083d3a23416fadc62847c45d14c25cbace86e7a72b2b350436978a0450","ParentId":"","RepoTags":["docker.io/library/alpine:latest"],"RepoDigests":["docker.io/library/alpine@sha256:1e42bbe2508154c9126d48c2b8a75420c3544343bf86fd041fb7527e017a4b4a","docker.io/library/alpine@sha256:ea3c5a9671f7b3f7eb47eab06f73bc6591df978b0d5955689a9e6f943aa368c0"],"Created":1725624336,"Size":9121900,"SharedSize":0,"VirtualSize":9121900,"Labels":null,"Containers":8,"Digest":"sha256:1e42bbe2508154c9126d48c2b8a75420c3544343bf86fd041fb7527e017a4b4a","History":["docker.io/library/alpine:latest"],"Names":["docker.io/library/alpine:latest"]},{"Id":"sha256:7a3f95c078122f959979fac556ae6f43746c9f32e5a66526bb503ed1d4adbd07","ParentId":"","RepoTags":["docker.io/library/nginx:latest"],"RepoDigests":["docker.io/library/nginx@sha256:bc5eac5eafc581aeda3008b4b1f07ebba230de2f27d47767129a6a905c84f470","docker.io/library/nginx@sha256:bf59355a6d8a42552f258c9ef7327e077309667bbb4d7a410ab891dea95bc3ba"],"Created":1727891735,"Size":200984620,"SharedSize":0,"VirtualSize":200984620,"Labels":{"maintainer":"NGINX Docker Maintainers \u003cdocker-maint@nginx.com\u003e"},"Containers":0,"Digest":"sha256:bc5eac5eafc581aeda3008b4b1f07ebba230de2f27d47767129a6a905c84f470","History":["docker.io/library/nginx:latest"],"Names":["docker.io/library/nginx:latest"]}]"#)
		]
	}
}
