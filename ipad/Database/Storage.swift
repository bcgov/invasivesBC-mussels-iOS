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
    
    public func getItemsToSync() -> [Object] {
        do {
            let realm = try Realm()
            let objs = realm.objects(WatercradftInspectionModel.self).filter("shouldSync == true").map { $0 }
            return Array(objs)
        } catch _ {}
        return [Object]()
    }
    
    public func getShifts() -> [ShiftModel] {
        do {
            let realm = try Realm()
            let objs = realm.objects(ShiftModel.self)
            return Array(objs)
        } catch _ {}
        return [ShiftModel]()
    }
}
