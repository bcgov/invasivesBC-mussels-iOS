//
//  RealmRequests.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-28.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

struct RealmRequests {

    static func saveObject<T: Object>(object: T) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(object)
            }
        } catch _ {
           
        }
    }
    
    static func updateObject<T: Object>(_ object: T) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(object, update: .modified)
            }
        } catch _ {
            
        }
    }

    static func deleteObject<T: Object>(_ object: T) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(object)
            }
        } catch _ {
            
        }
    }

    static func getObject<T: Object>(_ object: T.Type) -> [T]? {
        do {
            let realm = try Realm()
            let objs = realm.objects(object).map { $0 }
            return Array(objs)
        } catch _ {
            
        }
        return nil
    }
}
