## MyBrainTechnologiesSDK

<!--[![Platforms](https://img.shields.io/cocoapods/p/MyBrainTechnologiesSDK.svg)](https://cocoapods.org/pods/MyBrainTechnologiesSDK) -->
<!-- [![License](https://img.shields.io/cocoapods/l/MyBrainTechnologiesSDK.svg)](https://raw.githubusercontent.com/MyBrainTechnologies/MyBrainTechnologiesSDK/master/LICENSE) -->

<!-- [![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/MyBrainTechnologiesSDK.svg)](https://cocoapods.org/pods/MyBrainTechnologiesSDK) -->


<!--[![Travis](https://img.shields.io/travis/MyBrainTechnologies/MyBrainTechnologiesSDK/master.svg)](https://travis-ci.org/MyBrainTechnologies/MyBrainTechnologiesSDK/branches)
[![JetpackSwift](https://img.shields.io/badge/JetpackSwift-framework-red.svg)](http://github.com/JetpackSwift/Framework)-->

Swift iOS SDK for MyBrainTechnologies Headset

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [License](#license)

## <a name="requirements"></a> Requirements

- iOS 13.6+
- Xcode 12.0+
- Swift 5.5


## <a name="installation"></a> Installation

### Manually

#### Compile Binaries

Run the target `fastlane` in the Xcode project. It will generate a `MyBrainTechnologiesSDK.xcframework` in the root/build folder.

#### Embeded Binaries

- Download the latest release from `http://www.melomind.com/en/`
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- Add the downloaded `MyBrainTechnologiesSDK.xcframework`.
- And that's it!

<br />

## <a name="usage"></a> Usage

### Headset connection / disconnection

```swift
import MyBrainTechnologiesSDK

class MyClass: , MelomindEngineDelegate {

    ...

  func connectToHeadset() {
    MBTClientV2.shared.connectToBlueetooth()
  }

  func disconnectFromHeadset() {
    MBTClientV2.shared.disconnect()
  }

    ...
}
```

<br />

### Notification

The SDK is based on asynchronus communication. Hence a lot of information will be passed using the delagate pattern. 3 delegate are available

```swift
// Information about the ble state (connection or disconnection)
public weak var bleDelegate: MBTBLEBluetoothDelegate?

// Information about the A2DP state (connection or disconnection)
public weak var a2dpDelegate: MBTA2DPBluetoothDelegate?

// Information about the data acquisition like battery level or eeg/ims value handling
public weak var acquisitionDelegate: MBTAcquisitionDelegate?
```

<br />

### Getting EEG data

#### Start listening to EEG stream

```swift
class MyClass {
    func startEegStream() {
        MBTClientV2.shared.startStream()
    }

    func startEegStream() {
        MBTClientV2.shared.stopStream()
    }
}

extension MyClass: MBTAcquisitionDelegate {
    func didUpdateEEGData(_ eegPacket: MBTEEGPacket) {
        // use eegPacket.
    }
}
```


<br />

### Getters

Multiple getters are available.

```swift
// The information of the connected headset
MBTClientV2.shared.deviceInformation

// The most recent battery value.
MBTClientV2.shared.lastBatteryLevel
```

<br />

## <a name="license"></a> License

MyBrainTechnologiesSDK is released under the MIT license. See [LICENSE](https://github.com/MyBrainTechnologies/MyBrainTechnologiesSDK/blob/master/LICENSE) for details.
