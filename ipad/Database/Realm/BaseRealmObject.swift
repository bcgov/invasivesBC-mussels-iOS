//
//  BaseRealmObject.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-28.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import Realm
import RealmSwift


protocol BaseRealmObject {
    var localId: String { get set }
    var userId: String { get set }
    var remoteId: Int { get set }
    var shouldSync: Bool { get set }

    func toDictionary() -> [String: Any]
}
