import Foundation

/*******************************************************************************
 * MelomindEngineDelegate
 *
 * General delegate of the SDK for MelomindEngine.
 * Get data or information from the Headset out the SDK.
 *
 ******************************************************************************/

public protocol MelomindEngineDelegate:
  MBTBluetoothEventDelegate,
  MBTBluetoothA2DPDelegate,
  MBTEEGAcquisitionDelegate,
  MBTDeviceAcquisitionDelegate
{}
