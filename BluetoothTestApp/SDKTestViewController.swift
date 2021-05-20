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


  /******************** SDK ********************/

  let sdk = MBTBluetoothManagerV2()

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

  }

  //----------------------------------------------------------------------------
  // MARK: - Action
  //----------------------------------------------------------------------------

  @IBAction func startScan(_ sender: UIButton) {
    sdk.startScanning()
  }

}
