import Foundation

/*******************************************************************************
 * BluetoothConnectionHistory
 *
 * Store and retrieve bluetooth connections states history.
 *
 ******************************************************************************/
class BluetoothConnectionHistory {

  //----------------------------------------------------------------------------
  // MARK: - Properties
  //----------------------------------------------------------------------------

  /******************** History ********************/

  private var stateHistory: [Bool]

  let historySize: Int

  /******************** Interpretation of history ********************/

  var isConnected: Bool {
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
