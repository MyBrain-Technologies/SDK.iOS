import Foundation

extension MBTClient {

  /// Get the mean alpha power of the current session.
  /// Also populates sessionConfidence() data.
  public var sessionMeanAlphaPower: Float {
    return MBTMelomindAnalysis.sessionMeanAlphaPower()
  }

  public var sessionMeanRelativeAlphaPower: Float {
    return MBTMelomindAnalysis.sessionMeanRelativeAlphaPower()
  }

  /// Get the confidence rate of the current session.
  public var sessionConfidence: Float {
    return MBTMelomindAnalysis.sessionConfidence()
  }

  /// Get the alpha powers of the current session.
  public var sessionAlphaPowers: [Float] {
    let alphaPowers = MBTMelomindAnalysis.sessionAlphaPowers()
    return alphaPowers?.filter { $0 is Float } as? [Float] ?? []
  }

  /// Get the relative alpha powers of the current session.
  public var sessionRelativeAlphaPowers: [Float] {
    let relativeAlphaPowers = MBTMelomindAnalysis.sessionRelativeAlphaPowers()
    return relativeAlphaPowers?.filter { $0 is Float } as? [Float] ?? []
  }

  /// Get qualities of the current session.
  /// Qualities are multiplexed by channels ([q1c1,q1c2,q2c1,q2c2,q3c1,...])
  /// CALL AFTER `sessionMeanAlphaPower` or `sessionMeanRelativeAlphaPower`.
  public var sessionQualities: [Float] {
    let qualities = MBTMelomindAnalysis.sessionQualities()
    return qualities?.filter { $0 is Float } as? [Float] ?? []
  }

}
