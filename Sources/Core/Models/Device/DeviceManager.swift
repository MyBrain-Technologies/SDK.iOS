import Foundation

/*******************************************************************************
 * DeviceManager
 *
 * *MBTDevice* model DB Manager.
 *
 ******************************************************************************/

#warning("TODO: Remove Database???")

class DeviceManager {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /// The headset bluetooth profile name to connect to.
  static var connectedDeviceName: String? {
    didSet {
      log.verbose("Connected device name: \(connectedDeviceName ?? "nil")")
    }
  }

  /// Get Register Device
  /// - Returns: The array DB-saved *[MBTDevice]* instance
  static var registeredDevices: [MBTDevice] {
    return [MBTDevice](RealmManager.shared.realm.objects(MBTDevice.self))
  }

  /// Get BLE device informations of the connected MBT device.
  /// - Returns: The DB-saved *MBTDeviceInformations* instance.
  static var deviceInformation: MBTDeviceInformations? {
    // Get current device.
    return getCurrentDevice()?.deviceInfos
  }

  /// Get EEG data samp rate of the connected device.
  /// - Returns: The *sampRate* of the current *MBTDevice*.
  static var deviceSampleRate: Int? {
    return getCurrentDevice()?.sampRate
  }

  /// Get the number of channels of the connected device.
  /// - Returns: The *nbChannels* of the current *MBTDevice*.
  static var deviceChannelCount: Int? {
    return getCurrentDevice()?.nbChannels
  }

  /// Get EEGPacket length of the connected device.
  /// - Returns: The *eegPacketLength* of the current *MBTDevice*.
  static var deviceEEGPacketLength: Int? {
    return getCurrentDevice()?.eegPacketLength
  }

  static var deviceQrCode: String? {
    return getCurrentDevice()?.qrCode
  }

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  /// Update *deviceInformations* of the newly connected device record in the DB.
  /// - Parameters:
  ///     - deviceInfos: *MBTDeviceInformations* from BLE to record.
  class func updateDeviceInformations(_ deviceInfos: MBTDeviceInformations) {
    // Get the myBrainTechnologies device connected.
    if let device = getCurrentDevice() {
      // Save the new device infos to Realm Database
      try? RealmManager.shared.realm.write {
        device.deviceInfos!.productName =
          deviceInfos.productName ?? device.deviceInfos!.productName
        device.deviceInfos!.deviceId =
          deviceInfos.deviceId ?? device.deviceInfos!.deviceId
        device.deviceInfos!.hardwareVersion =
          deviceInfos.hardwareVersion ?? device.deviceInfos!.hardwareVersion
        device.deviceInfos!.firmwareVersion =
          deviceInfos.firmwareVersion ?? device.deviceInfos!.firmwareVersion
      }
    }
  }

  /// Update *deviceBatteryLevel*
  /// - Parameters:
  ///     - batterylevel: *Int* from BLE to record.
  class func updateDeviceBatteryLevel(_ batteryLevel: Int) {
    // Get the myBrainTechnologies device connected.
    if let device = getCurrentDevice() {
      // Save the new battery status to Realm Database
      try? RealmManager.shared.realm.write {
        if batteryLevel >= 0 && batteryLevel <= 6 {
          device.batteryLevel = batteryLevel
        } else {
          device.batteryLevel = -1
        }
      }
    }
  }

  /// Init device with Melomind specifications.
  class func updateDeviceToMelomind() {

    // Acquisition Electrodes
    let acquisition1 = MBTAcquistionLocation()
    acquisition1.type = .p3
    let acquisition2 = MBTAcquistionLocation()
    acquisition2.type = .p4

    // Reference Electrode
    let reference = MBTAcquistionLocation()
    reference.type = .m1

    // Ground Electrode
    let ground = MBTAcquistionLocation()
    ground.type = .m2

    // Save Melomind info to DB
    if let device = getCurrentDevice() {
      try? RealmManager.shared.realm.write {
        #warning("Change for indus5 here")
        device.sampRate = 250
        device.nbChannels = 2
        device.eegPacketLength = 250

        // Add electrodes locations value.
        device.acquisitionLocations.removeAll()
        device.acquisitionLocations.append(acquisition1)
        device.acquisitionLocations.append(acquisition2)
        device.referencesLocations.removeAll()
        device.referencesLocations.append(reference)
        device.groundsLocations.removeAll()
        device.groundsLocations.append(ground)
      }
    }
  }

  /// Get the DB-saved device or create one if any.
  /// - Returns: The DB-saved *MBTDevice* instance.
  class func getCurrentDevice() -> MBTDevice? {
    // If no device saved in DB, then create it.
    guard let deviceName = connectedDeviceName, !deviceName.isEmpty else {
      return nil
    }

    if let device = getDevice(name: deviceName) {
      return device
    } else {
      let newDevice = MBTDevice()
      newDevice.deviceName = deviceName

      try? RealmManager.shared.realm.write {
        RealmManager.shared.realm.add(newDevice)
      }

      return newDevice
    }
  }

  /// Deinit all properties of deviceInfos
  class func resetDeviceInfo() {
    if let currentDevice = DeviceManager.getCurrentDevice() {
      try? RealmManager.shared.realm.write {
        currentDevice.deviceInfos?.productName = nil
        currentDevice.deviceInfos?.deviceId = nil
        currentDevice.deviceInfos?.hardwareVersion = nil
        currentDevice.deviceInfos?.firmwareVersion = nil
      }
    }
  }

  /// Remove the current device from Realm DB
  class func removeCurrentDevice() -> Bool {
    guard let deviceToDelete = connectedDeviceName else {
      return false
    }

    return removeDevice(deviceToDelete)
  }

  /// Remove the device with deviceName == deviceName from Realm DB
  class func removeDevice(_ deviceName: String) -> Bool {
    guard let device = getDevice(name: deviceName) else { return false }

    try? RealmManager.shared.realm.write {
      RealmManager.shared.realm.delete(device)
    }
    return true
  }

  class func getDevice(name: String) -> MBTDevice? {
    let realmObjects = RealmManager.shared.realm.objects(MBTDevice.self)
    return realmObjects.filter("deviceName = %@", name).first
  }

}
