import XCPlayground
import BrightFutures
import Result

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

struct RandomResult {
  let imageUrl: URL
  
  init?(_ dictionary: JSON?) {
    guard let data = dictionary?["data"], let urlString = data["image_url"] as? String else {
      return nil
    }
    if let url = URL(string: urlString) {
      self.imageUrl = url
    } else {
      return nil
    }
  }
}

enum ImageFetchError: Error {
  case NetworkError(NSError)
  case RandomResourceParseError
  case ImageDataMalformed
  
  var message: String {
    switch self {
    case .NetworkError(let error): return error.localizedDescription
    case .RandomResourceParseError: return "Parsing the random image resource failed"
    case .ImageDataMalformed: return "Image data corrupted"
    }
  }
}

struct RandomImageAPI {
  static func get() -> Future<UIImage, ImageFetchError> {
    return self.getRandomResult().flatMap { result in
      return self.getImage(randomResult: result)
    }
  }
  
  private static func getRandomResult() -> Future<RandomResult, ImageFetchError> {
    let future: Future<Data, NSError> = URLSession.shared.dataTask(with: Endpoints.Random)

    return future.mapError { ImageFetchError.NetworkError($0) }
      .flatMap { data -> Future<RandomResult, ImageFetchError> in
        let json = JSONParser.decode(data: data)
        return Future(result: Result(RandomResult(json), failWith: ImageFetchError.RandomResourceParseError))
      }
  }
  
  private static func getImage(randomResult: RandomResult) -> Future<UIImage, ImageFetchError> {
    let future: Future<Data, NSError> = URLSession.shared.dataTask(with: randomResult.imageUrl)
    
    return future.mapError { ImageFetchError.NetworkError($0) }
      .flatMap { data -> Future<UIImage, ImageFetchError> in
        return Future(result: Result(UIImage(data: data), failWith: ImageFetchError.ImageDataMalformed))
      }
  }
}

RandomImageAPI.get()
  .onSuccess { image in
    let plxInspectMe = image
  }.onFailure { error in
    print(error.message)
  }
