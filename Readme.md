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

- iOS 8.0+
- Xcode 8.0+
- Swift 3.0, 3.1, 3.2, and 4.0


## <a name="installation"></a> Installation

### Manually

#### Embeded Binaries

- Download the latest release from `http://www.melomind.com/en/`
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- Add the downloaded `MyBrainTechnologiesSDK.framework`.
- **Add dependencies** : <a href="https://github.com/Alamofire/Alamofire" target="_blank">Alamofire</a> & <a href="https://realm.io/docs/swift/latest/" target="_blank">Realm Swift</a> 
- And that's it!

<br />
## <a name="usage"></a> Usage

### Headset connection / disconnection

#### Connect Bluetooth LE (EEG) and A2DP (audio)

```swift
import MyBrainTechnologiesSDK

class VC: UIViewController, MelomindEngineDelegate {

    ...
 
 MelomindEngine.connectEEGAndA2DP(_ deviceName: String, withDelegate: self)
 
    ...
}
```

#### Only Connect Bluetooth LE (EEG)

```swift
import MyBrainTechnologiesSDK

class VC: UIViewController, MBTBluetoothEventDelegate {

    ...

    MelomindEngine.connectEEG(_ deviceName: String, withDelegate: self)

    ...
}
```

#### Disconnection of the headset

```swift
MelomindEngine.disconnect()
```

<br />
### Getting EEG data

#### Start listening to EEG stream

```swift
MelomindEngine.startStream()
```

#### Stop listening to EEG stream
```swift
MelomindEngine.stopStream()
```

<br />
### Getters

#### Device Informations getter (as *MBTDeviceInformations* instance)
```swift
MelomindEngine.getDeviceInformations()
```
 
#### Session results getter (as JSON in *kwak* scheme)
```swift
MelomindEngine.getSessionJSON()
```

<br />
## <a name="license"></a> License

MyBrainTechnologiesSDK is released under the MIT license. See [LICENSE](https://github.com/MyBrainTechnologies/MyBrainTechnologiesSDK/blob/master/LICENSE) for details.
