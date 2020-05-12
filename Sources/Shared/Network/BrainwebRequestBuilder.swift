import Foundation
import Alamofire

struct BrainwebRequestBuilder {

  private let path = "/ingest-legacy"

  func build(fromBase baseURL: String) -> URLRequest? {
    guard var url = URL(string: baseURL) else { return nil }

    url.appendPathComponent(path)

    return URLRequest(url: url)
  }

  func buildIngestPost(fromBase baseURL: String,
                       token: String) -> URLRequest? {
    guard var urlRequest = build(fromBase: baseURL) else { return nil }

    urlRequest.httpMethod = HTTPMethod.post.rawValue
    urlRequest.timeoutInterval = TimeInterval(20)

    urlRequest.setValue("Bearer " + token,
                        forHTTPHeaderField: "Authorization")

    return urlRequest
  }
}
