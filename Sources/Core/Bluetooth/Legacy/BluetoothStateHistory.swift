import Foundation

/*******************************************************************************
 * bluetoothStatesHistory
 *
 * Store and retrieve bluetooth connections states history.
 *
 ******************************************************************************/
// Good
class BluetoothStateHistory {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** History ********************/

  private var stateHistory: [Bool]

  let historySize: Int

  /******************** Interpretation of history ********************/

  var isPoweredOn: Bool {
    return stateHistory.last ?? false
  }

  var hasNoHistory: Bool {
    return stateHistory.count == 0
  }

  var historyIsFull: Bool {
    return stateHistory.count >= historySize
  }

  //----------------------------------------------------------------------------
  // MARK: - Initialization
  //----------------------------------------------------------------------------

  init(historySize: Int = 3) {
    self.historySize = historySize
    self.stateHistory = []
  }

  //----------------------------------------------------------------------------
  // MARK: - Methods
  //----------------------------------------------------------------------------

  func addState(isConnected: Bool) {
    stateHistory.append(isConnected)
    clearHistorySize()
  }

  private func clearHistorySize() {
    while stateHistory.count > historySize {
      stateHistory.removeFirst()
    }
  }

}
