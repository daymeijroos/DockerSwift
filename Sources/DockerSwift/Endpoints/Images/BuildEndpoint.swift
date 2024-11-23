import NIOHTTP1
import NIO
import Foundation

struct BuildEndpoint: UploadEndpoint {
	var body: Body?

	typealias Response = AsyncThrowingStream<ByteBuffer, Error>
	typealias Body = ByteBuffer
	var method: HTTPMethod = .POST

	private let buildConfig: BuildConfig

	// Some Query String items have to be encoded as JSON
	private let encoder: JSONEncoder
	// Decode build output message
	private let decoder = JSONDecoder()

	var path: String { "build" }

	var queryArugments: [URLQueryItem] {
		let cacheFrom = try? encoder.encode(buildConfig.cacheFrom)
		let buildArgs = {
			let args = try? encoder.encode(buildConfig.buildArgs)
			return args.map { String(decoding: $0, as: UTF8.self) }
		}()
		let labels = {
			let value = try? encoder.encode(buildConfig.labels)
			return value.map { String(decoding: $0, as: UTF8.self) }
		}()

		let queryItems: [URLQueryItem?] = [
			URLQueryItem(name: "dockerfile", value: "\(buildConfig.dockerfile)"),
			buildConfig.extraHosts.map { URLQueryItem(name: "extrahosts", value: $0) },
			buildConfig.remote.map { URLQueryItem(name: "remote", value: $0.absoluteString) },
			URLQueryItem(name: "q", value: "\(buildConfig.quiet)"),
			URLQueryItem(name: "nocache", value: buildConfig.noCache.description),
			URLQueryItem(name: "cachefrom", value: String(decoding: cacheFrom ?? Data(), as: UTF8.self)),
			URLQueryItem(name: "pull", value: buildConfig.pull.description),
			URLQueryItem(name: "rm", value: buildConfig.rm.description),
			URLQueryItem(name: "forcerm", value: buildConfig.forceRm.description),
			URLQueryItem(name: "memory", value: buildConfig.memory.description),
			URLQueryItem(name: "memswap", value: buildConfig.memorySwap.description),
			URLQueryItem(name: "cpushares", value: buildConfig.cpuShares.description),
			buildConfig.cpusetCpus.map { URLQueryItem(name: "cpusetcpus", value: $0) },
			URLQueryItem(name: "cpuperiod", value: buildConfig.cpuPeriod.description),
			URLQueryItem(name: "cpuquota", value: buildConfig.cpuQuota.description),
			buildConfig.shmSizeBytes.map { URLQueryItem(name: "shmsize", value: $0.description) },
			URLQueryItem(name: "squash", value: buildConfig.squash.description),
			buildConfig.networkMode.map { URLQueryItem(name: "networkmode", value: $0) },
			buildConfig.platform.map { URLQueryItem(name: "platform", value: $0) },
			buildConfig.target.map { URLQueryItem(name: "target", value: $0) },
			buildConfig.outputs.map { URLQueryItem(name: "outputs", value: $0) },
			buildArgs.map { URLQueryItem(name: "buildargs", value: $0) },
			labels.map { URLQueryItem(name: "labels", value: $0) },
		]

		return queryItems.compactMap(\.self) + (buildConfig.repoTags?.map { URLQueryItem(name: "t", value: $0) } ?? [])
	}

	init(buildConfig: BuildConfig, context: ByteBuffer) {
		self.buildConfig = buildConfig
		self.body = context
		self.encoder = .init()
	}

	func map(response: Response) async throws -> AsyncThrowingStream<BuildStreamOutput, Error>  {
		return AsyncThrowingStream<BuildStreamOutput, Error> { continuation in
			Task {
				for try await var buffer in response {
					let totalDataSize = buffer.readableBytes
					while buffer.readerIndex < totalDataSize {
						if buffer.readableBytes == 0 {
							continuation.finish()
						}
						guard let data = buffer.readData(length: buffer.readableBytes) else {
							continuation.finish(throwing: DockerLogDecodingError.dataCorrupted("Unable to read \(totalDataSize) bytes as Data"))
							return
						}
						let splat = data.split(separator: 10 /* ascii code for \n */)
						guard splat.count >= 1 else {
							print("\n!!! Expected json terminated by line return")
							continuation.finish(throwing: DockerError.unknownResponse("Expected json terminated by line return"))
							return
						}
						for streamItem in splat {
							let model: BuildStreamOutput!
							do {
								model = try decoder.decode(BuildStreamOutput.self, from: streamItem)
							}
							catch(let error) {
								continuation.finish(throwing: error)
								return
							}
							guard model.message == nil else {
								continuation.finish(throwing: DockerError.message(model.message!))
								return
							}
							continuation.yield(model)
						}
					}
				}
				continuation.finish()
			}
		}
	}
}
