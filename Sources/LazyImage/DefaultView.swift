import SwiftUI
import AsyncCache
import Cache

#if os(macOS)
typealias PlatformImage = NSImage
#else
typealias PlatformImage = UIImage
#endif

extension SwiftUI.Image {
  init(image: PlatformImage) {
    #if os(macOS)
    self.init(nsImage: image)
    #else
    self.init(uiImage: image)
    #endif
  }
}

struct DefaultView: View {
  let result: Swift.Result<Data, any Error>?
  
  var body: some View {
    if let result {
      switch result {
      case .success(let data):
        if let image = PlatformImage(data: data) {
          Image(image: image)
            .resizable()
        } else {
          Text("Invalid Data")
        }
      case .failure(let error):
        Text(error.localizedDescription)
      }
    } else {
      ProgressView()
    }
  }
}

extension LazyImage<DefaultView> {
  public init(request: URLRequest, provider: DataProvider = .lazyImage, expiry: Expiry = .never) {
    self.request = request
    self.provider = provider
    self.expiry = expiry
    self.content = { DefaultView(result: $0) }
  }

  public init(url: URL, provider: DataProvider = .lazyImage, expiry: Expiry = .never) {
    self.init(request: .init(url: url), provider: .lazyImage, expiry: expiry)
  }
}
