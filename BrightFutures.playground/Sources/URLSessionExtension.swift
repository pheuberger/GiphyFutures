import Foundation
import BrightFutures

// For this basic example, we're going to ignore the URLResponse
public extension URLSession {
  func dataTask(with url: URL) -> Future<Data, NSError> {
    let promise = Promise<Data, NSError>()
    
    self.dataTask(with: url) { data, _, error in
      if let data = data {
        promise.success(data)
      } else {
        let fallback = NSError(domain: "Network Error", code: 2016, userInfo: nil)
        promise.failure(error as? NSError ?? fallback)
      }
      }.resume()
    return promise.future
  }
}
