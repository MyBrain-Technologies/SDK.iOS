//
//  SDKTestViewController.swift
//  BluetoothTestApp
//
//  Created by Laurent on 20/05/2021.
//  Copyright © 2021 MyBrainTechnologies. All rights reserved.
//

import UIKit
import MyBrainTechnologiesSDK

class SDKTestViewController: UIViewController {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** Outlets ********************/

  @IBOutlet weak private var scanningButton: UIButton!
  @IBOutlet weak private var batteryLevelLabel: UILabel!

  @IBOutlet weak private var productNameLabel: UILabel!
  @IBOutlet weak private var deviceIdLabel: UILabel!
  @IBOutlet weak private var hardwareVersionLabel: UILabel!
  @IBOutlet weak private var firmwareVersionLabel: UILabel!

  @IBOutlet weak private var eegRawDataLabel: UILabel!

  /******************** SDK ********************/

  let sdk: MBTClientV2 = .shared

  //----------------------------------------------------------------------------
  // MARK: - Lifecycle
  //----------------------------------------------------------------------------

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  private func setup() {
    setupSDK()
    setupBatteryView()
    setupDeviceInformation()
  }

  private func setupSDK() {
    sdk.bleDelegate = self
    sdk.a2dpDelegate = self
    sdk.acquisitionDelegate = self
  }

  private func setupBatteryView() {
    batteryLevelLabel.text = "0"
  }

  private func setupDeviceInformation() {
    productNameLabel.text = "Unknown"
    deviceIdLabel.text = "Unknown"
    hardwareVersionLabel.text = "Unknown"
    firmwareVersionLabel.text = "Unknown"
  }

  //----------------------------------------------------------------------------
  // MARK: - Action
  //----------------------------------------------------------------------------

  @IBAction func startScan(_ sender: UIButton) {
    sdk.connectToBlueetooth()
  }

  @IBAction func changeStreamingEEGState(_ sender: UISwitch) {
    if sender.isOn {
      sdk.startImsStreaming()
//      sdk.startStream(shouldUseQualityChecker: true)
      sdk.batteryLevelRefreshInterval = 0
    } else {
//      sdk.stopStream()
      sdk.stopImsStreaming()
      sdk.batteryLevelRefreshInterval = 2
    }
  }

  @IBAction func readBattery(_ sender: Any) {
//    sdk.readBatteryStatus()
    let batteryLevel = sdk.lastBatteryLevel
    print("Battery level: \(batteryLevel) %")
    batteryLevelLabel.text = String("\(batteryLevel) %")
  }

}

//==============================================================================
// MARK: - MBTBLEBluetoothDelegate
//==============================================================================

extension SDKTestViewController: MBTBLEBluetoothDelegate {

  func didBluetoothStateChange(isBluetoothOn: Bool) {

  }

  func didUpdateSampleBufferSize(sampleBufferSize: Int) {
    print("sampleBufferSize: \(sampleBufferSize)")
  }

  func didConnect() {
    print("BLE connection succeed!")
  }

  func didConnect(deviceInformation: DeviceInformation) {
    productNameLabel.text = deviceInformation.productName
    deviceIdLabel.text = deviceInformation.deviceId
    hardwareVersionLabel.text = deviceInformation.hardwareVersion.rawValue
    firmwareVersionLabel.text = deviceInformation.firmwareVersion
  }

  func didConnectionFail(error: Error?) {
    print("BLE connection failed: ")
    if let error = error {
      print("With error")
      print(error.localizedDescription)
    }
  }

  func didDisconnect(error: Error?) {
    print("BLE disconnected:")
    if let error = error {
      print("With error")
      print(error.localizedDescription)
    }
  }

}

//==============================================================================
// MARK: - MBTA2DPBluetoothDelegate
//==============================================================================

extension SDKTestViewController: MBTA2DPBluetoothDelegate {

  func didRequestA2DPConnection() {
    print("A2DP connection requested!")
  }

  func didAudioA2DPConnect() {
      print("A2DP connection succeed!")
  }

  func didAudioA2DPDisconnect(error: Error?) {
    print("A2DP disconnected:")
    if let error = error {
      print("With error")
      print(error.localizedDescription)
    }
  }

}

//==============================================================================
// MARK: - MBTAcquisitionDelegate
//==============================================================================

extension SDKTestViewController: MBTAcquisitionDelegate {

  func didUpdateBatteryLevel(_ batteryLevel: Int) {
    print("Battery level: \(batteryLevel) %")
    batteryLevelLabel.text = String("\(batteryLevel) %")
  }

  func didUpdateSaturationStatus(_ status: Int) {

  }

  func didUpdateEEGData(_ eegPacket: MBTEEGPacket) {

  }

  func didUpdateEEGRawData(_ data: Data) {
    print("EEg raw data: \(data)")
    let text = String(data: data, encoding: .ascii)
    eegRawDataLabel.text = text
  }

  func didUpdateImsData(_ imsPacket: MbtImsPacket) {
    print(imsPacket.coordinates.first)
  }

}


