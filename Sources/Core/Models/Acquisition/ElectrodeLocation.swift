import Foundation

/// Enum of differents electrodes possible locations.
public enum ElectrodeLocation: String, Codable {
  case fpz = "Fpz"
  case fp1 = "Fp1"
  case fp2 = "Fp2"

  case af7 = "AF7"
  case af3 = "AF3"
  case afz = "AFz"
  case af4 = "AF4"
  case ad8 = "AD8"

  case f9 = "F9"
  case f7 = "F7"
  case f5 = "F5"
  case f3 = "F3"
  case f1 = "F1"
  case fz = "Fz"
  case f2 = "F2"
  case f4 = "F4"
  case f6 = "F6"
  case f8 = "F8"
  case f10 = "F10"

  case ft9 = "FT9"
  case ft7 = "FT7"
  case fc5 = "FC5"
  case fc3 = "FC3"
  case fc1 = "FC1"
  case fcz = "FCz"
  case fc2 = "FC2"
  case fc4 = "FC4"
  case fc6 = "FC6"
  case ft8 = "FT8"
  case ft10 = "FT10"

  case t7 = "T7"
  case c5 = "C5"
  case c3 = "C3"
  case c1 = "C1"
  case cz = "Cz"
  case c2 = "C2"
  case c4 = "C4"
  case c6 = "C6"
  case t8 = "T8"

  case tp9 = "TP9"
  case tp7 = "TP7"
  case cp5 = "CP5"
  case cp3 = "CP3"
  case cp1 = "CP1"
  case cpz = "CPz"
  case cp2 = "CP2"
  case cp4 = "CP4"
  case cp6 = "CP6"
  case tp8 = "TP8"
  case tp10 = "TP10"

  case p9 = "P9"
  case p7 = "P7"
  case p5 = "P5"
  case p3 = "P3"
  case p1 = "P1"
  case pz = "Pz"
  case p2 = "P2"
  case p4 = "P4"
  case p6 = "P6"
  case p8 = "P8"
  case p10 = "P10"

  case po3 = "PO3"
  case poz = "POz"
  case po4 = "PO4"

  case po7 = "PO7"
  case o1 = "O1"
  case oz = "Oz"
  case o2 = "O2"
  case po8 = "PO8"

  case po9 = "PO9"
  case o9 = "O9"
  case iz = "Iz"
  case o10 = "O10"
  case po10 = "PO10"

  case m1 = "M1" // Mastoid 1
  case m2 = "M2"  // Mastoid 2

  case acc = "ACC"

  case ext1 = "EXT1"
  case ext2 = "EXT2"
  case ext3 = "EXT3"

  case null1 = "NULL1"
  case null2 = "NULL2"
  case null3 = "NULL3"
}
