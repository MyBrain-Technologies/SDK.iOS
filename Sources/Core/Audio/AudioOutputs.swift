import Foundation
import AVFoundation
// Good
struct AudioOutputs {

  /// Audio outputs for the current session
  var outputs: [AVAudioSessionPortDescription] {
    return AVAudioSession.sharedInstance().currentRoute.outputs
  }

  /// Return only outputs where portName contains the legacy audio prefix
  var outputsWithLegacyPrefix: [AVAudioSessionPortDescription] {
    return filter(portNameContains: Constants.DeviceName.a2dpPrefixLegacy)
  }

  /// Return only outputs where portName contains the expected audio prefix
  var outputsWithPrefix: [AVAudioSessionPortDescription] {
    return filter(portNameContains: Constants.DeviceName.a2dpPrefix)
  }

  /// Return only outputs where portName match a QRCode format
  var outputsWithQrCode: [AVAudioSessionPortDescription] {
    return outputs.filter({ $0.portName.isQrCode })
  }

  /// Return only the first output found where portName has a recognized melomind format
  var melomindOutput: AVAudioSessionPortDescription? {
    if let output = outputsWithLegacyPrefix.first {
      return output
    } else if let output = outputsWithPrefix.first {
      return output
    } else if let output = outputsWithQrCode.first {
      return output
    }

    return nil
  }

  //----------------------------------------------------------------------------
  // MARK: - Tools
  //----------------------------------------------------------------------------

  /// Filter outputs where its port name contains the given string
  func filter(
    portNameContains portName: String
  ) -> [AVAudioSessionPortDescription] {
    return outputs.filter {
      $0.portName.lowercased().range(of: portName) != nil
    }
  }

}
