import Foundation
import Alamofire

/*******************************************************************************
 * BrainwebRequest
 *
 * Helper to deal with Brain Web (server).
 *
 ******************************************************************************/
struct BrainwebRequest {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  static var shared = BrainwebRequest()

  var accessTokens = ""

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  private init() {}

  //----------------------------------------------------------------------------
  // MARK: - Upload
  //----------------------------------------------------------------------------

  /// Send JSON to BrainWeb server.
  ///
  /// - Parameters:
  ///   - fileURL: A *URL* of the file which sends
  ///   - baseURL: A *String* of BrainWeb base url (without the endpoint)
  ///   - completion: A block which is execute after the success or the failure
  ///   of the request
  func sendJSON(_ fileURL: URL,
                baseURL: String,
                completion: @escaping (Bool) -> Void) {
    let request = BrainwebRequestBuilder().buildIngestPost(fromBase: baseURL,
                                                           token: accessTokens)
    guard let urlRequest = request else {
      log.error("Cannot build request to brainweb", context: baseURL)
      return completion(false)
    }

    // Encode

    let encoder = Alamofire.URLEncoding.default
    guard let encodedRequest = try? encoder.encode(urlRequest, with: [:]) else {
      return completion(false)
    }

    let multipartFormData: (MultipartFormData) -> Void = {
      $0.append(fileURL, withName: "eeg")
    }

    // Upload
    Alamofire.upload(multipartFormData: multipartFormData, with: encodedRequest)
    { encodingResult in
      guard let request = self.didEncodeRequest(encodingResult) else {
        return completion(false)
      }

      self.uploadRequest(request) { completion($0) }
    }
  }

  private func didEncodeRequest(
    _ encodeResult: SessionManager.MultipartFormDataEncodingResult
  ) -> UploadRequest? {
    switch encodeResult {
    case .success(let upload, _, _): return upload
    case .failure(let error):
      log.error("Encode request failed", context: error)
      return nil
    }
  }

  private func uploadRequest(_ request: UploadRequest,
                             completion: @escaping (Bool) -> Void) {
    request.responseJSON { response in
      log.info("Send JSON to Brainweb response", context: response)

      guard let statusCode = response.response?.statusCode else {
        return completion(false)
      }

      let isValid = statusCode >= 200 && statusCode < 300
      return completion(isValid)
    }
  }

}
