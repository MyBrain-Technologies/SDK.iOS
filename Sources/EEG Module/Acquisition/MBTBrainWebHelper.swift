import Foundation
import Alamofire

/*******************************************************************************
 * MBTBrainWebHelper
 *
 * Helper to deal with Brain Web (server).
 *
 ******************************************************************************/

struct MBTBrainWebHelper {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  static var accessTokens = ""

  static var path = "/ingest-legacy"

  //----------------------------------------------------------------------------
  // MARK: - Request
  //----------------------------------------------------------------------------

  private static func generateUrlRequestConvertible(
    fromBaseURL baseURL: String
  ) -> URLRequestConvertible? {
    guard var url = URL(string: baseURL) else { return nil }
    url.appendPathComponent(MBTBrainWebHelper.path)

    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = HTTPMethod.post.rawValue
    urlRequest.timeoutInterval = TimeInterval(20)
    urlRequest.setValue("Bearer " + accessTokens,
                        forHTTPHeaderField: "Authorization")

    return urlRequest as URLRequestConvertible
  }

  //----------------------------------------------------------------------------
  // MARK: - File explorer
  //----------------------------------------------------------------------------

  private static func generateTableEegPacketsJSONFiles() -> [URL]? {
     do {
       let fileManager = FileManager.default
       let documentDirectory = try fileManager.url(for: .documentDirectory,
                                                   in: .userDomainMask,
                                                   appropriateFor: nil,
                                                   create: false)
       let eegPacketJSONRecordingsPath =
         documentDirectory.appendingPathComponent("eegPacketJSONRecordings")

       let tableEegPacketsJSONFiles =
         try fileManager.contentsOfDirectory(at: eegPacketJSONRecordingsPath,
                                             includingPropertiesForKeys: nil,
                                             options: .skipsHiddenFiles)
       return tableEegPacketsJSONFiles
     } catch {
       prettyPrint(log.ln("sendAllJSONToBrainWeb - "))
       prettyPrint(log.error(error as NSError))
       return nil
     }
   }

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
  static func sendJSONToBrainWeb(_ fileURL: URL,
                                 baseURL: String,
                                 completion: @escaping (Bool) -> Void) {
    guard let urlRequest =
      MBTBrainWebHelper.generateUrlRequestConvertible(fromBaseURL: baseURL)
      else {
        completion(false)
        return
    }

    guard let request =
      try? Alamofire.URLEncoding.default.encode(urlRequest,
                                                with: [String:String]())
      else {
        completion(false)
        return
    }

    let multipartFormData: (MultipartFormData) -> Void = { multipartFormData in
      multipartFormData.append(fileURL, withName: "eeg")
    }

    let encodingCompletion:
      (SessionManager.MultipartFormDataEncodingResult) -> Void = {
        encodingResult in
        switch encodingResult {
          case .success(let upload, _, _):
            upload.responseJSON { response in
              let logMessage =
                log.url("sendJSONToBrainWeb response : \n \(response)")
              prettyPrint(logMessage)
              if let statusCode = response.response?.statusCode,
                statusCode >= 200 && statusCode < 300 {
                completion(true)
              } else {
                completion(false)
              }
          }

          case .failure(let encodingError):
            let logMessage =
              log.url("sendJSONToBrainWeb failure : \(encodingError)")
            prettyPrint(logMessage)
            completion(false)
        }
    }

    Alamofire.upload(multipartFormData: multipartFormData,
                     with: request,
                     encodingCompletion: encodingCompletion)
  }

  /// Send ALL JSON to BrainWeb server.
  ///
  /// - Parameters:
  ///   - baseURL: A *String* of BrainWeb base url (without the endpoint)
  ///   - completion: A block which is execute after the success or the failure
  ///   of the request
  static func sendAllJSONToBrainWeb(_ baseURL: String,
                                    completion: @escaping (Bool) -> Void ) {
    guard let urlRequest =
      MBTBrainWebHelper.generateUrlRequestConvertible(fromBaseURL: baseURL)
      else {
        completion(false)
        return
    }

    guard let tableEegPacketsJSONFiles =
      generateTableEegPacketsJSONFiles() else {
        completion(false)
        return
    }

    for fileURL in tableEegPacketsJSONFiles {
      if let request =
        try? Alamofire.URLEncoding.default.encode(urlRequest,
                                                  with: [String:String]()) {
        let multipartFormData: (MultipartFormData) -> Void = {
          multipartFormData in
          multipartFormData.append(fileURL, withName: "eeg")
        }

        let encodingCompletion:
          (SessionManager.MultipartFormDataEncodingResult) -> Void = {
            encodingResult in
            switch encodingResult {
              case .success(let upload, _, _):
                upload.responseJSON { response in
                  let logMessage =
                    log.url("sendALLJsonToBrainWeb - response : \n\(response)")
                  prettyPrint(logMessage)
                  if response.response?.statusCode == 201 {
                    MBTJSONHelper.removeFile(fileURL)
                    completion(true)
                  }
                  completion(false)
              }

              case .failure(let encodingError):
                let logMessage =
                  log.url("sendAllJSONToBrainWeb - failure : \(encodingError)")
                prettyPrint(logMessage)
                completion(false)
            }
        }

        Alamofire.upload(multipartFormData:multipartFormData,
                         with: request,
                         encodingCompletion: encodingCompletion)
      }
    }
  }

}
