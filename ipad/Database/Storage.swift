//
//  Storage.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-03.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Storage {
    public static let shared = Storage()
    private init() {}
    
    public func getSyncableItems() -> [Object] {
        do {
            let realm = try Realm()
            let objs = realm.objects(BaseRealmObject.self).filter("syncable == true").map { $0 }
            return Array(objs)
        } catch _ {}
        return [Object]()
    }
    
    public func getItemsToSync() -> [Object] {
        do {
            let realm = try Realm()
            let objs = realm.objects(BaseRealmObject.self).filter("shouldSync == true").map { $0 }
            return Array(objs)
        } catch _ {}
        return [Object]()
    }
}
