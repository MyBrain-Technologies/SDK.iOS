//
//  RealmEntityManager.swift
//  Melomind
//
//  Created by Baptiste Rasschaert on 11/08/2016.
//  Copyright © 2016 Baptiste Rasschaert. All rights reserved.
//

import Foundation
import RealmSwift

/// Class to manage the structure to create entities manager.
class RealmEntityManager: Object {
    /// Structure declaration to create DB Entity managers.
    struct RealmManager {
        /// The *Realm* object.
        static let realm = try! Realm()
    }

}
