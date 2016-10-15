import Foundation

public typealias JSON = Dictionary<String, AnyObject>

public struct JSONParser {
  public static func decode(data: Data) -> JSON? {
    guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
      return nil
    }
    return json as? JSON
  }
}
