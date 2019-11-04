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


class BaseRealmObject: Object {
    @objc dynamic var localId: String = {
           return UUID().uuidString
    }()
       
    override class func primaryKey() -> String? {
        return "localId"
    }
    var remoteId: Int = -1
    var syncable: Bool = true
    var shouldSync: Bool = false
    
    func toDictionary() -> [String : Any] {
        return [:]
    }
    
    
}
