import Foundation
import AVFoundation

/*******************************************************************************
 * AudioNotification
 *
 * Interpret notification on the audio scope.
 *
 ******************************************************************************/
// Good
struct AudioNotification {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  private let notificationInfo: [AnyHashable: Any]

  var lastAudioRoute: AVAudioSessionRouteDescription? {
    let notifKey = AVAudioSessionRouteChangePreviousRouteKey
    return notificationInfo[notifKey] as? AVAudioSessionRouteDescription
  }

  var lastAudioPort: AVAudioSessionPortDescription? {
    return lastAudioRoute?.outputs.first
  }

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(_ notification: Notification) {
    self.notificationInfo = notification.userInfo ?? [:]
  }
}
