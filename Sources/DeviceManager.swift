import Foundation

/// *MBTDevice* model DB Manager.
class DeviceManager: MBTRealmEntityManager {

  //MARK: Variable
  /// The headset bluetooth profile name to connect to.
  static var connectedDeviceName: String?

  //MARK: Methods

  /// Update *deviceInformations* of the newly connected device record in the DB.
  /// - Parameters:
  ///     - deviceInfos: *MBTDeviceInformations* from BLE to record.
  class func updateDeviceInformations(_ deviceInfos:MBTDeviceInformations) {
    // Get the myBrainTechnologies device connected.
    if let device = getCurrentDevice() {
      // Save the new device infos to Realm Database
      try! RealmManager.shared.realm.write {
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
  class func updateDeviceBatteryLevel(_ batteryLevel:Int) {
    // Get the myBrainTechnologies device connected.
    if let device = getCurrentDevice() {
      // Save the new battery status to Realm Database
      try! RealmManager.shared.realm.write {
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
      try! RealmManager.shared.realm.write {
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
    if let deviceName = connectedDeviceName, !deviceName.isEmpty {
      if  let device = RealmManager.shared.realm.objects(MBTDevice.self).filter("deviceName = %@", deviceName).first {
        return device
      } else {
        let newDevice = MBTDevice()
        newDevice.deviceName = deviceName

        try! RealmManager.shared.realm.write {
          RealmManager.shared.realm.add(newDevice)
        }

        return newDevice
      }
    }
    return nil
  }

  /// Get Register Device
  /// - Returns : The array DB-saved *[MBTDevice]* instance
  class func getRegisteredDevices() -> [MBTDevice] {
    return [MBTDevice](RealmManager.shared.realm.objects(MBTDevice.self))
  }

  /// Get BLE device informations of the connected MBT device.
  /// - Returns: The DB-saved *MBTDeviceInformations* instance.
  class func getDeviceInfos() -> MBTDeviceInformations? {
    // Get current device.
    return getCurrentDevice()?.deviceInfos
  }

  /// Get EEG data samp rate of the connected device.
  /// - Returns: The *sampRate* of the current *MBTDevice*.
  class func getDeviceSampRate() -> Int? {
    return getCurrentDevice()?.sampRate
  }

  /// Get the number of channels of the connected device.
  /// - Returns: The *nbChannels* of the current *MBTDevice*.
  class func getChannelsCount() -> Int? {
    return getCurrentDevice()?.nbChannels
  }

  /// Get EEGPacket length of the connected device.
  /// - Returns: The *eegPacketLength* of the current *MBTDevice*.
  class func getDeviceEEGPacketLength() -> Int? {
    return getCurrentDevice()?.eegPacketLength
  }

  class func getDeviceQrCode() -> String? {
    return getCurrentDevice()?.qrCode
  }

  /// Deinit all properties of deviceInfos
  class func resetDeviceInfo() {
    if let currentDevice = DeviceManager.getCurrentDevice() {
      try! RealmManager.shared.realm.write {
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

    let deviceNameToDelete:String! = deviceName

    if let device = RealmManager.shared.realm.objects(MBTDevice.self).filter("deviceName = %@", deviceNameToDelete ?? "").first {
      try! RealmManager.shared.realm.write {
        RealmManager.shared.realm.delete(device)
      }

      return true
    }

    return false
  }

}
