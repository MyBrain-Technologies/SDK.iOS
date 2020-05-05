import Foundation

protocol MBTError: Error {

  var rawValue: Int { get }

  var error: Error { get }
}

extension MBTError {
  var error: Error {
    let error = NSError(
      domain: "Bluetooth Manager",
      code: rawValue,
      userInfo: [NSLocalizedDescriptionKey: localizedDescription]
    )
    return error as Error
  }
}

enum BluetoothError: Int, MBTError {
  case deviceInfoUnavailable = 909
  case deviceNotConnected = 916
  case deviceInfoTimeOut = 917
  case bluetoothLowEnergyConnectionTimeOut = 918
  case bluetoothPoweredOff = 919
  case bluetoothLowEnergyPoweredOff = 920
  case bluetoothPairingDenied = 921
  case audioConnectionTimeOut = 924

//  var value: Int { return rawValue }

  var localizedDescription: String {
    switch self {
    case .deviceInfoUnavailable: return "Device informations are not available"
    case .deviceNotConnected: return "Device not connected"
    case .deviceInfoTimeOut: return "Timeout while getting device informations"
    case .bluetoothLowEnergyConnectionTimeOut:
      return "Timeout while connecting bluetooth low energy"
    case .bluetoothPoweredOff: return "Bluetooth is powered off"
    case .bluetoothLowEnergyPoweredOff:
      return "Bluetooth low energy is powered off"
    case .bluetoothPairingDenied:
      return "Bluetooth pairing demand have been denied"
    case .audioConnectionTimeOut: return "Timeout while connecting audio"
    }
  }
}

enum OADError: Int, MBTError {
  case reconnectionAfterUpdateFailed = 908
  case firmwareAlreadyUpToDate = 910
  case bluetoothConnectionLost = 911
  case transferTimeOut = 912
  case transferPreparationFailed = 913
  case transferInterrupted = 914
  case firmwareVersionInvalidAfterUpdate = 915

  var localizedDescription: String {
    switch self {
    case .reconnectionAfterUpdateFailed:
      return "Impossible to reconnect to headset after updating the headset"
    case .firmwareAlreadyUpToDate:
      return "Latest firmware version already installed"
    case .bluetoothConnectionLost:
      return "Bluetooth connection have been lost during update"
    case .transferTimeOut: return "Timeout while transfering data to headset"
    case .transferPreparationFailed:
      return "Prepare data transfer to headset failed"
    case .transferInterrupted: return "Transfer cannot be completed."
    case .firmwareVersionInvalidAfterUpdate:
      return "Headset firmware version is not the one expected after update"
    }
  }
}

enum OADCommandError: Int, MBTError {
  case audioUnpaired = 922
  case audioAldreadyConnected = 923
  case badBDAddr = 925

  var localizedDescription: String {
    switch self {
    case .audioUnpaired: return "Audio is not paired to the device"
    case .audioAldreadyConnected:
      return "Audio is already connected to another device"
    case .badBDAddr: return "Bad BDADDR"
    }
  }
}
