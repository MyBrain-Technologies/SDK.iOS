import Foundation

/// Enum of differents electrodes possible locations.
enum ElectrodeLocation: Int, Codable {
    case fpz
    case fp1
    case fp2

    case af7
    case af3
    case afz
    case af4
    case ad8

    case f9
    case f7
    case f5
    case f3
    case f1
    case fz
    case f2
    case f4
    case f6
    case f8
    case f10

    case ft9
    case ft7
    case fc5
    case fc3
    case fc1
    case fcz
    case fc2
    case fc4
    case fc6
    case ft8
    case ft10

    case t7
    case c5
    case c3
    case c1
    case cz
    case c2
    case c4
    case c6
    case t8

    case tp9
    case tp7
    case cp5
    case cp3
    case cp1
    case cpz
    case cp2
    case cp4
    case cp6
    case tp8
    case tp10

    case p9
    case p7
    case p5
    case p3
    case p1
    case pz
    case p2
    case p4
    case p6
    case p8
    case p10

    case po3
    case poz
    case po4

    case po7
    case o1
    case oz
    case o2
    case po8

    case po9
    case o9
    case iz
    case o10
    case po10

    case m1 // Mastoid 1
    case m2  // Mastoid 2

    case acc

    case ext1
    case ext2
    case ext3

    case null1
    case null2
    case null3

    var stringValue: String {
        switch self {
        case .fpz: return "Fpz"
        case .fp1: return "Fp1"
        case .fp2: return "Fp2"

        case .af7: return "AF7"
        case .af3: return "AF3"
        case .afz: return "AFz"
        case .af4: return "AF4"
        case .ad8: return "AD8"

        case .f9: return "F9"
        case .f7: return "F7"
        case .f5: return "F5"
        case .f3: return "F3"
        case .f1: return "F1"
        case .fz: return "Fz"
        case .f2: return "F2"
        case .f4: return "F4"
        case .f6: return "F6"
        case .f8: return "F8"
        case .f10: return "F10"

        case .ft9: return "FT9"
        case .ft7: return "FT7"
        case .fc5: return "FC5"
        case .fc3: return "FC3"
        case .fc1: return "FC1"
        case .fcz: return "FCz"
        case .fc2: return "FC2"
        case .fc4: return "FC4"
        case .fc6: return "FC6"
        case .ft8: return "FT8"
        case .ft10: return "FT10"

        case .t7: return "T7"
        case .c5: return "C5"
        case .c3: return "C3"
        case .c1: return "C1"
        case .cz: return "Cz"
        case .c2: return "C2"
        case .c4: return "C4"
        case .c6: return "C6"
        case .t8: return "T8"

        case .tp9: return "TP9"
        case .tp7: return "TP7"
        case .cp5: return "CP5"
        case .cp3: return "CP3"
        case .cp1: return "CP1"
        case .cpz: return "CPz"
        case .cp2: return "CP2"
        case .cp4: return "CP4"
        case .cp6: return "CP6"
        case .tp8: return "TP8"
        case .tp10: return "TP10"

        case .p9: return "P9"
        case .p7: return "P7"
        case .p5: return "P5"
        case .p3: return "P3"
        case .p1: return "P1"
        case .pz: return "Pz"
        case .p2: return "P2"
        case .p4: return "P4"
        case .p6: return "P6"
        case .p8: return "P8"
        case .p10: return "P10"

        case .po3: return "PO3"
        case .poz: return "POz"
        case .po4: return "PO4"

        case .po7: return "PO7"
        case .o1: return "O1"
        case .oz: return "Oz"
        case .o2: return "O2"
        case .po8: return "PO8"

        case .po9: return "PO9"
        case .o9: return "O9"
        case .iz: return "Iz"
        case .o10: return "O10"
        case .po10: return "PO10"

        case .m1: return "M1" // Mastoid 1
        case .m2: return "M2"  // Mastoid 2

        case .acc: return "ACC"

        case .ext1: return "EXT1"
        case .ext2: return "EXT2"
        case .ext3: return "EXT3"

        case .null1: return "NULL1"
        case .null2: return "NULL2"
        case .null3: return "NULL3"
        }
    }
}

public enum ElectrodeType: String, Codable {
  case acquisition = "acquisition"
  case reference = "reference"
  case ground = "ground"
}
