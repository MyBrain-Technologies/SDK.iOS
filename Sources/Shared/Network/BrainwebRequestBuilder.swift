import Foundation
import Alamofire

/*******************************************************************************
 * BrainwebRequestBuilder
 *
 * Build a request object depending on the type of request expected
 *
 ******************************************************************************/
struct BrainwebRequestBuilder {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  private let path = "/ingest-legacy"
  private let timeout = TimeInterval(20)

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  /// Build a url request from a `baseURL`
  func build(fromBase baseURL: String) -> URLRequest? {
    guard var url = URL(string: baseURL) else { return nil }

    url.appendPathComponent(path)

    return URLRequest(url: url)
  }

  /// Build a POST ingest request on the given brainweb url
  func buildIngestPost(fromBase baseURL: String,
                       token: String) -> URLRequest? {
    guard var urlRequest = build(fromBase: baseURL) else { return nil }

    urlRequest.httpMethod = HTTPMethod.post.rawValue
    urlRequest.timeoutInterval = timeout

    urlRequest.setValue("Bearer " + token,
                        forHTTPHeaderField: "Authorization")

    return urlRequest
  }
}
