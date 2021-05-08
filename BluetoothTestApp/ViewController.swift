//
//  ViewController.swift
//  BluetoothTestApp
//
//  Created by Laurent on 08/05/2021.
//  Copyright © 2021 MyBrainTechnologies. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  @IBOutlet weak private var powerSwitch: UISwitch!

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
    setupPowerSwitch()
  }

  private func setupPowerSwitch() {
    powerSwitch.isOn = false
  }

  //----------------------------------------------------------------------------
  // MARK: - Actions
  //----------------------------------------------------------------------------

  @IBAction func SwitchPowerState(_ sender: UISwitch) {
    if sender.isOn {
      turnOnBluetooth()
    } else {
      turnOffBluetooth()
    }
  }

  //----------------------------------------------------------------------------
  // MARK: - Bluetooth
  //----------------------------------------------------------------------------

  private func turnOnBluetooth() {

  }

  private func turnOffBluetooth() {

  }

}

