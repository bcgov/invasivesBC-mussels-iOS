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
    
    public func getCodeTable(type: CodeTableType)  -> [CodeTableModel] {
        do {
            let realm = try Realm()
            let objs = realm.objects(CodeTableModel.self).filter("type == \(type)").map { $0 }
            return Array(objs)
        } catch _ {}
        return [CodeTableModel]()
    }
    
    public func getCodeTables() -> [CodeTableModel] {
        do {
            let realm = try Realm()
            let objs = realm.objects(CodeTableModel.self)
            return Array(objs)
        } catch _ {}
        return [CodeTableModel]()
    }
    
    public func deleteCodeTables() {
        let all = getCodeTables()
        for each in all {
            RealmRequests.deleteObject(each)
        }
    }
    
    public func getWaterBodyTables() -> [WaterBodyTableModel] {
        do {
            let realm = try Realm()
            let objs = realm.objects(WaterBodyTableModel.self)
            return Array(objs)
        } catch _ {}
        return [WaterBodyTableModel]()
    }
    
    public func deteleWaterBodyTables() {
        let all = getWaterBodyTables()
        for each in all {
            RealmRequests.deleteObject(each)
        }
    }
}
