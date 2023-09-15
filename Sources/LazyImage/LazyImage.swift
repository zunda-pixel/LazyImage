import AsyncCache
import SwiftUI
import Cache

public struct LazyImage<Content: View>: View {
  public let request: URLRequest
  public let provider: DataProvider
  public let expiry: Expiry
  public let content: (Swift.Result<Data, any Error>?) -> Content
  
  public init(
    request: URLRequest,
    provider: DataProvider = .lazyImage,
    expiry: Expiry = .never,
    @ViewBuilder content: @escaping (Swift.Result<Data, any Error>?) -> Content
  ) {
    self.request = request
    self.provider = provider
    self.expiry = expiry
    self.content = content
  }

  public init(
    url: URL,
    provider: DataProvider = .lazyImage,
    expiry: Expiry = .never,
    @ViewBuilder content: @escaping (Swift.Result<Data, any Error>?) -> Content) {
      self.init(
        request: .init(url: url),
        provider: .lazyImage,
        expiry: expiry,
        content: content
      )
  }
  
  @State var result: Swift.Result<Data, any Error>? = nil

  public var body: some View {
    content(result)
      .task {
        do {
          let data = try await provider.data(request: request, expiry: expiry)
          self.result = .success(data)
        } catch {
          self.result = .failure(error)
        }
      }
  }
}

#Preview {
  let url = URL(string: "https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png")!
  return LazyImage(url: url)
    .scaledToFit()
    .frame(maxWidth: 300)
}

extension DataProvider {
  static public let lazyImage: DataProvider = .init(storage: .lazyImage)
}

extension Storage<DataStoreKey, Data> {
  static let lazyImage: Storage<DataStoreKey, Data> = try! .init(
    diskConfig: .lazyImage,
    memoryConfig: .lazyImage,
    transformer: .init(toData: { $0 }, fromData: { $0 })
  )
}

extension DiskConfig {
  #if os(iOS) || os(tvOS)
  static let lazyImage: DiskConfig = .init(
    name: "LazyImage",
    expiry: .never,
    maxSize: 0,
    directory: nil,
    protectionType: nil
  )
  #else
  static let lazyImage: DiskConfig = .init(
    name: "LazyImage",
    expiry: .never,
    maxSize: 0,
    directory: nil
  )
  #endif
}

extension MemoryConfig {
  static let lazyImage: MemoryConfig = .init(
    expiry: .never,
    countLimit: 0,
    totalCostLimit: 0
  )
}
