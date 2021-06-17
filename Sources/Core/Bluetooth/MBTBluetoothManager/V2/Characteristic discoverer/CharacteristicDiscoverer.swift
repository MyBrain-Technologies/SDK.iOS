import Foundation
import CoreBluetooth

protocol CharacteristicDiscoverable {
  associatedtype CharacteristicContainerType

  var didDiscoverAllCharacteristics:
    ((CharacteristicContainerType) -> Void)? { get set }

  init(characteristicCBUUIDs: [CBUUID])

  func reset()

  func discover(characteristic: CBCharacteristic)
}

class CharacteristicDiscoverer {

  //----------------------------------------------------------------------------
  // MARK: - Typealias
  //----------------------------------------------------------------------------

  #warning("TODO: USE CBUIIDS!")
  typealias PreIndus5CharacteristicToCBCharacteristic =
    [MBTCharacteristic.PreIndus5: CBCharacteristic?]

  typealias PostIndus5CharacteristicToCBCharacteristic =
    [MBTCharacteristic.PostIndus5: CBCharacteristic?]

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** CBUUIDs ********************/

  private var preIndus5CharacteristicMap =
    PreIndus5CharacteristicToCBCharacteristic()

  private var postIndus5CharacteristicMap =
    PostIndus5CharacteristicToCBCharacteristic()

  /******************** Callbacks ********************/

  var didDiscoverAllPreIndus5Characteristics:
    ((PreIndus5CharacteristicContainer) -> Void)?

  var didDiscoverAllPostIndus5Characteristics:
    ((PostIndus5CharacteristicContainer) -> Void)?

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(preIndus5Characteristics: [MBTCharacteristic.PreIndus5]
        = MBTCharacteristic.PreIndus5.allCases,
       postIndus5Characteristics: [MBTCharacteristic.PostIndus5]
        = MBTCharacteristic.PostIndus5.allCases
  ) {

    for characteristic in preIndus5Characteristics {
      preIndus5CharacteristicMap.updateValue(nil, forKey: characteristic)
    }

    for characteristic in postIndus5Characteristics {
      postIndus5CharacteristicMap.updateValue(nil, forKey: characteristic)
    }
  }

  //----------------------------------------------------------------------------
  // MARK: - Lifecycle
  //----------------------------------------------------------------------------

  func reset() {
    preIndus5CharacteristicMap.forEach { (key, value) in
      preIndus5CharacteristicMap.updateValue(nil, forKey: key)
    }

    postIndus5CharacteristicMap.forEach { (key, value) in
      postIndus5CharacteristicMap.updateValue(nil, forKey: key)
    }

  }

  //----------------------------------------------------------------------------
  // MARK: - Discover
  //----------------------------------------------------------------------------

  func discover(characteristic: CBCharacteristic) {
    preIndus5CharacteristicMap.forEach { (key, value) in
      if key.uuid == characteristic.uuid {
        preIndus5CharacteristicMap[key] = characteristic
      }
    }

    postIndus5CharacteristicMap.forEach { (key, value) in
      if key.uuid == characteristic.uuid {
        postIndus5CharacteristicMap[key] = characteristic
      }
    }

    if preIndus5CharacteristicMap.allSatisfy(
        { (key, value) in value != nil }
    ) {
      handleDiscoveryForAllPreIndus5Characteristics()
    } else if postIndus5CharacteristicMap.allSatisfy(
                { (key, value) in value != nil }
    ) {
      handleDiscoveryForAllPostIndus5Characteristics()
    }

  }

  private func handleDiscoveryForAllPreIndus5Characteristics() {
    guard let productName =
            preIndus5CharacteristicMap[.productName] as? CBCharacteristic else {
      assertionFailure("Handle error")
      return
    }

    guard let serialNumber =
            preIndus5CharacteristicMap[.serialNumber] as? CBCharacteristic
    else {
      assertionFailure("Handle error")
      return
    }

    guard let hardwareRevision =
            preIndus5CharacteristicMap[.hardwareRevision] as? CBCharacteristic
    else {
      assertionFailure("Handle error")
      return
    }

    guard let firmwareRevision =
            preIndus5CharacteristicMap[.firmwareRevision] as? CBCharacteristic
    else {
      assertionFailure("Handle error")
      return
    }

    guard let brainActivityMeasurement =
            preIndus5CharacteristicMap[.brainActivityMeasurement]
            as? CBCharacteristic else {
      assertionFailure("Handle error")
      return
    }

    guard let deviceState =
            preIndus5CharacteristicMap[.deviceBatteryStatus]
            as? CBCharacteristic else {
      assertionFailure("Handle error")
      return
    }

    guard let headsetStatus =
            preIndus5CharacteristicMap[.headsetStatus] as? CBCharacteristic
    else {
      assertionFailure("Handle error")
      return
    }

    guard let mailBox =
            preIndus5CharacteristicMap[.mailBox] as? CBCharacteristic else {
      assertionFailure("Handle error")
      return
    }

    guard let oadTransfert =
            preIndus5CharacteristicMap[.oadTransfert] as? CBCharacteristic
    else {
      assertionFailure("Handle error")
      return
    }

    let preIndus5CharacteristicContainer = PreIndus5CharacteristicContainer(
      productName: productName,
      serialNumber: serialNumber,
      hardwareRevision: hardwareRevision,
      firmwareRevision: firmwareRevision,
      brainActivityMeasurement: brainActivityMeasurement,
      deviceState: deviceState,
      headsetStatus: headsetStatus,
      mailBox: mailBox,
      oadTransfert: oadTransfert)

    didDiscoverAllPreIndus5Characteristics?(preIndus5CharacteristicContainer)
  }

  private func handleDiscoveryForAllPostIndus5Characteristics() {
    guard let tx = postIndus5CharacteristicMap[.tx] as? CBCharacteristic else {
      assertionFailure("Handle error")
      return
    }

    guard let rx = postIndus5CharacteristicMap[.rx] as? CBCharacteristic else {
      assertionFailure("Handle error")
      return
    }

    let postIndus5CharacteristicContainer =
      PostIndus5CharacteristicContainer(tx: tx, rx: rx)

    didDiscoverAllPostIndus5Characteristics?(postIndus5CharacteristicContainer)
  }

}





//==============================================================================
// MARK: - Lab
//==============================================================================

//enum CharacteristicDiscovererError : Error {
//  case invalidCharacteristic
//  case invalidCharacteristicContainerBuild
//}
//
//protocol CharacteristicDiscoverableContainerProtocol: class {
//  associatedtype CharacteristicContainer
//
//  var cbuuidCharacteristicMap: [CBUUID: CBCharacteristic?] { get set }
//
//  var hasAllCharacteristics: Bool { get }
//
//  func reset()
//
//  func reset(with characteristicCBUUIDs: [CBUUID])
//
//  @discardableResult func add(characteristic: CBCharacteristic) -> Bool
//
//  func discover(characteristic: CBCharacteristic) -> Result<CharacteristicContainer?, Error>
//
//  func generateAllCharacteristicsContainer() -> CharacteristicContainer?
//}
//
//extension CharacteristicDiscoverableContainerProtocol {
//
//  var hasAllCharacteristics: Bool {
//    return cbuuidCharacteristicMap.allSatisfy(
//        { (key, value) in value != nil }
//    )
//  }
//
//  func reset(with characteristicCBUUIDs: [CBUUID]) {
//    cbuuidCharacteristicMap.removeAll()
//
//    for cbuuids in characteristicCBUUIDs {
//      cbuuidCharacteristicMap.updateValue(nil, forKey: cbuuids)
//    }
//  }
//
//  func reset() {
//    cbuuidCharacteristicMap.forEach { (key, value) in
//      cbuuidCharacteristicMap.updateValue(nil, forKey: key)
//    }
//  }
//
//  @discardableResult func add(characteristic: CBCharacteristic) -> Bool {
//    for key in cbuuidCharacteristicMap.keys {
//      if key == characteristic.uuid {
//        cbuuidCharacteristicMap[key] = characteristic
//        return true
//      }
//    }
//
//    return false
//  }
//
//  func discover(characteristic: CBCharacteristic) ->
//  Result<CharacteristicContainer?, Error> {
//    guard add(characteristic: characteristic) else {
//      return .failure(CharacteristicDiscovererError.invalidCharacteristic)
//    }
//
//    guard hasAllCharacteristics == true else { return .success((nil)) }
//
//    guard let characteristicContainer = generateAllCharacteristicsContainer()
//    else {
//      let error =
//        CharacteristicDiscovererError.invalidCharacteristicContainerBuild
//      return .failure(error)
//    }
//
//    return .success((characteristicContainer))
//  }
//
//}
//
//class CharacteristicDiscoverablePreIndus5Container:
//  CharacteristicDiscoverableContainerProtocol {
//
//  //----------------------------------------------------------------------------
//  // MARK: - Porperties
//  //----------------------------------------------------------------------------
//
//  var cbuuidCharacteristicMap: [CBUUID : CBCharacteristic?] = [:]
//
//  //----------------------------------------------------------------------------
//  // MARK: - Container
//  //----------------------------------------------------------------------------
//
//  func generateAllCharacteristicsContainer() ->
//  PreIndus5CharacteristicContainer? {
//    guard let productName = cbuuidCharacteristicMap[
//            MBTCharacteristic.PreIndus5.productName.uuid
//    ] as? CBCharacteristic else {
//      assertionFailure("Handle error")
//      return nil
//    }
//
//    guard let serialNumber = cbuuidCharacteristicMap[
//      MBTCharacteristic.PreIndus5.serialNumber.uuid
//    ] as? CBCharacteristic else {
//      assertionFailure("Handle error")
//      return nil
//    }
//
//    guard let hardwareRevision = cbuuidCharacteristicMap[
//      MBTCharacteristic.PreIndus5.hardwareRevision.uuid
//    ] as? CBCharacteristic else {
//      assertionFailure("Handle error")
//      return nil
//    }
//
//    guard let firmwareRevision = cbuuidCharacteristicMap[
//      MBTCharacteristic.PreIndus5.firmwareRevision.uuid
//    ] as? CBCharacteristic else {
//      assertionFailure("Handle error")
//      return nil
//    }
//
//    guard let brainActivityMeasurement = cbuuidCharacteristicMap[
//      MBTCharacteristic.PreIndus5.brainActivityMeasurement.uuid
//    ] as? CBCharacteristic else {
//      assertionFailure("Handle error")
//      return nil
//    }
//
//    guard let deviceState = cbuuidCharacteristicMap[
//      MBTCharacteristic.PreIndus5.deviceBatteryStatus.uuid
//    ] as? CBCharacteristic else {
//      assertionFailure("Handle error")
//      return nil
//    }
//
//    guard let headsetStatus = cbuuidCharacteristicMap[
//      MBTCharacteristic.PreIndus5.headsetStatus.uuid
//    ] as? CBCharacteristic else {
//      assertionFailure("Handle error")
//      return nil
//    }
//
//    guard let mailBox = cbuuidCharacteristicMap[
//      MBTCharacteristic.PreIndus5.mailBox.uuid
//    ] as? CBCharacteristic else {
//      assertionFailure("Handle error")
//      return nil
//    }
//
//    guard let oadTransfert = cbuuidCharacteristicMap[
//      MBTCharacteristic.PreIndus5.oadTransfert.uuid
//    ] as? CBCharacteristic else {
//      assertionFailure("Handle error")
//      return nil
//    }
//
//    let characteristicContainer = PreIndus5CharacteristicContainer(
//      productName: productName,
//      serialNumber: serialNumber,
//      hardwareRevision: hardwareRevision,
//      firmwareRevision: firmwareRevision,
//      brainActivityMeasurement: brainActivityMeasurement,
//      deviceState: deviceState,
//      headsetStatus: headsetStatus,
//      mailBox: mailBox,
//      oadTransfert: oadTransfert
//    )
//
//    return characteristicContainer
//  }
//
//}
//
//class CharacteristicDiscoverablePostIndus5Container:
//  CharacteristicDiscoverableContainerProtocol {
//
//  //----------------------------------------------------------------------------
//  // MARK: - Porperties
//  //----------------------------------------------------------------------------
//
//  var cbuuidCharacteristicMap: [CBUUID : CBCharacteristic?] = [:]
//
//  //----------------------------------------------------------------------------
//  // MARK: - Container
//  //----------------------------------------------------------------------------
//
//  func generateAllCharacteristicsContainer() ->
//  PostIndus5CharacteristicContainer? {
//    guard let tx = cbuuidCharacteristicMap[
//      MBTCharacteristic.PostIndus5.tx.uuid
//    ] as? CBCharacteristic else {
//      assertionFailure("Handle error")
//      return nil
//    }
//
//    guard let rx = cbuuidCharacteristicMap[
//      MBTCharacteristic.PostIndus5.rx.uuid
//    ] as? CBCharacteristic else {
//      assertionFailure("Handle error")
//      return nil
//    }
//
//    guard let mailBox = cbuuidCharacteristicMap[
//      MBTCharacteristic.PostIndus5.mailBox.uuid
//    ] as? CBCharacteristic else {
//      assertionFailure("Handle error")
//      return nil
//    }
//
//    let characteristicContainer =
//      PostIndus5CharacteristicContainer(tx: tx, rx: rx, mailBox: mailBox)
//
//    return characteristicContainer
//  }
//
//}
//
//
//
//
//
//
//
//
//
//
//
//protocol CharacteristicDiscoverable {
//  associatedtype CharacteristicContainerType
//
//  var didDiscoverAllCharacteristics:
//    ((CharacteristicContainerType) -> Void)? { get set }
//
//  var didFail: ((Error) -> Void)? { get set}
//
//  init(characteristicCBUUIDs: [CBUUID])
//
//  func reset()
//
//  func discover(characteristic: CBCharacteristic)
//}
//
//class CharacteristicPreIndus5Discoverer: CharacteristicDiscoverable {
//
//  //----------------------------------------------------------------------------
//  // MARK: - Properties
//  //----------------------------------------------------------------------------
//
//  /******************** CBUUIDs ********************/
//
//  private let discoverableContainer =
//    CharacteristicDiscoverablePreIndus5Container()
//
//  /******************** Callbacks ********************/
//
//  var didDiscoverAllCharacteristics:
//    ((PreIndus5CharacteristicContainer) -> Void)?
//
//  var didFail: ((Error) -> Void)?
//
//  //----------------------------------------------------------------------------
//  // MARK: - Initialization
//  //----------------------------------------------------------------------------
//
//  required init(characteristicCBUUIDs: [CBUUID]) {
//    discoverableContainer.reset(with: characteristicCBUUIDs)
//  }
//
//  //----------------------------------------------------------------------------
//  // MARK: - Lifecycle
//  //----------------------------------------------------------------------------
//
//  func reset() {
//    discoverableContainer.reset()
//  }
//
//  //----------------------------------------------------------------------------
//  // MARK: - Discover
//  //----------------------------------------------------------------------------
//
//  func discover(characteristic: CBCharacteristic) {
//    let result =
//      discoverableContainer.discover(characteristic: characteristic)
//
//    switch result {
//      case .success(let characteristicContainer):
//        if let container = characteristicContainer {
//          didDiscoverAllCharacteristics?(container)
//        }
//      case .failure(let error):
//        didFail?(error)
//    }
//  }
//
//}
//
//class CharacteristicPostIndus5Discoverer: CharacteristicDiscoverable {
//
//  //----------------------------------------------------------------------------
//  // MARK: - Properties
//  //----------------------------------------------------------------------------
//
//  /******************** CBUUIDs ********************/
//
//  private let discoverableContainer =
//    CharacteristicDiscoverablePostIndus5Container()
//
//  /******************** Callbacks ********************/
//
//  var didDiscoverAllCharacteristics:
//    ((PostIndus5CharacteristicContainer) -> Void)?
//
//  var didFail: ((Error) -> Void)?
//
//  //----------------------------------------------------------------------------
//  // MARK: - Initialization
//  //----------------------------------------------------------------------------
//
//  required init(characteristicCBUUIDs: [CBUUID]) {
//    discoverableContainer.reset(with: characteristicCBUUIDs)
//  }
//
//  //----------------------------------------------------------------------------
//  // MARK: - Lifecycle
//  //----------------------------------------------------------------------------
//
//  func reset() {
//    discoverableContainer.reset()
//  }
//
//  //----------------------------------------------------------------------------
//  // MARK: - Discover
//  //----------------------------------------------------------------------------
//
//  func discover(characteristic: CBCharacteristic) {
//    let result =
//      discoverableContainer.discover(characteristic: characteristic)
//
//    switch result {
//      case .success(let characteristicContainer):
//        if let container = characteristicContainer {
//          didDiscoverAllCharacteristics?(container)
//        }
//      case .failure(let error):
//        didFail?(error)
//    }
//  }
//
//}
