import XCPlayground
import BrightFutures
import Result

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

struct ImageUrlParser {
  static func decode(data: Data) -> URL? {
    let json = JSONParser.decode(data: data)
    let urlString = json?["data"]?["image_url"] as? String
    return urlString.flatMap(URL.init)
  }
}

struct ImageFetchError: Error {}

struct RandomImageAPI {
  static func get() -> Future<UIImage, ImageFetchError> {
    return URLSession.shared.dataTask(with: Endpoints.Random)
        .mapError { _ in ImageFetchError() }
        .flatMap { data -> Result<URL, ImageFetchError> in
          let url = ImageUrlParser.decode(data: data)
          return Result(url, failWith: ImageFetchError())
        }
        .flatMap { url -> Future<Data, ImageFetchError> in
          return URLSession.shared.dataTask(with: url)
              .mapError { _ in ImageFetchError() }
        }
        .flatMap { data -> Result<UIImage, ImageFetchError> in
          return Result(UIImage(data: data), failWith: ImageFetchError())
        }
  }
}

RandomImageAPI.get()
  .onSuccess {
    let plzInspect = $0
  }
  .onFailure { _ in
    print("something went wrong")
  }