import Foundation

/// Enum of differents electrodes possible locations.
enum ElectrodeLocation: Int {
    case Fpz
    case Fp1
    case Fp2

    case AF7
    case AF3
    case AFz
    case AF4
    case AD8

    case F9
    case F7
    case F5
    case F3
    case F1
    case Fz
    case F2
    case F4
    case F6
    case F8
    case F10

    case FT9
    case FT7
    case FC5
    case FC3
    case FC1
    case FCz
    case FC2
    case FC4
    case FC6
    case FT8
    case FT10

    case T7
    case C5
    case C3
    case C1
    case Cz
    case C2
    case C4
    case C6
    case T8

    case TP9
    case TP7
    case CP5
    case CP3
    case CP1
    case CPz
    case CP2
    case CP4
    case CP6
    case TP8
    case TP10

    case P9
    case P7
    case P5
    case P3
    case P1
    case Pz
    case P2
    case P4
    case P6
    case P8
    case P10

    case PO3
    case POz
    case PO4

    case PO7
    case O1
    case Oz
    case O2
    case PO8

    case PO9
    case O9
    case Iz
    case O10
    case PO10

    case M1 // Mastoid 1
    case M2  // Mastoid 2

    case ACC

    case EXT1
    case EXT2
    case EXT3

    case NULL1
    case NULL2
    case NULL3

    var stringValue:String {
        switch self {
        case .Fpz : return "Fpz"
        case .Fp1 : return "Fp1"
        case .Fp2 : return "Fp2"

        case .AF7 : return "AF7"
        case .AF3 : return "AF3"
        case .AFz : return "AFz"
        case .AF4 : return "AF4"
        case .AD8 : return "AD8"

        case .F9 : return "F9"
        case .F7 : return "F7"
        case .F5 : return "F5"
        case .F3 : return "F3"
        case .F1 : return "F1"
        case .Fz : return "Fz"
        case .F2 : return "F2"
        case .F4 : return "F4"
        case .F6 : return "F6"
        case .F8 : return "F8"
        case .F10 : return "F10"

        case .FT9 : return "FT9"
        case .FT7 : return "FT7"
        case .FC5 : return "FC5"
        case .FC3 : return "FC3"
        case .FC1 : return "FC1"
        case .FCz : return "FCz"
        case .FC2 : return "FC2"
        case .FC4 : return "FC4"
        case .FC6 : return "FC6"
        case .FT8 : return "FT8"
        case .FT10 : return "FT10"

        case .T7 : return "T7"
        case .C5 : return "C5"
        case .C3 : return "C3"
        case .C1 : return "C1"
        case .Cz : return "Cz"
        case .C2 : return "C2"
        case .C4 : return "C4"
        case .C6 : return "C6"
        case .T8 : return "T8"

        case .TP9 : return "TP9"
        case .TP7 : return "TP7"
        case .CP5 : return "CP5"
        case .CP3 : return "CP3"
        case .CP1 : return "CP1"
        case .CPz : return "CPz"
        case .CP2 : return "CP2"
        case .CP4 : return "CP4"
        case .CP6 : return "CP6"
        case .TP8 : return "TP8"
        case .TP10 : return "TP10"

        case .P9 : return "P9"
        case .P7 : return "P7"
        case .P5 : return "P5"
        case .P3 : return "P3"
        case .P1 : return "P1"
        case .Pz : return "Pz"
        case .P2 : return "P2"
        case .P4 : return "P4"
        case .P6 : return "P6"
        case .P8 : return "P8"
        case .P10 : return "P10"

        case .PO3 : return "PO3"
        case .POz : return "POz"
        case .PO4 : return "PO4"

        case .PO7 : return "PO7"
        case .O1 : return "O1"
        case .Oz : return "Oz"
        case .O2 : return "O2"
        case .PO8 : return "PO8"

        case .PO9 : return "PO9"
        case .O9 : return "O9"
        case .Iz : return "Iz"
        case .O10 : return "O10"
        case .PO10 : return "PO10"

        case .M1 : return "M1" // Mastoid 1
        case .M2 : return "M2"  // Mastoid 2

        case .ACC : return "ACC"

        case .EXT1 : return "EXT1"
        case .EXT2 : return "EXT2"
        case .EXT3 : return "EXT3"

        case .NULL1 : return "NULL1"
        case .NULL2 : return "NULL2"
        case .NULL3 : return "NULL3"
        }
    }
}
