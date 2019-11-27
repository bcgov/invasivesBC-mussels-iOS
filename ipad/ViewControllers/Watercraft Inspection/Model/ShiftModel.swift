//
//  ShiftModel.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-21.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

//extension ShiftModel: PropertyReflectable {}

class ShiftModel: Object, BaseRealmObject {
    
    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()
    
    override class func primaryKey() -> String? {
        return "localId"
    }
    
    @objc dynamic var remoteId: Int = -1 {
        didSet {
            if remoteId > 0 {
                set(value: "Completed", for: "status")
            }
        }
    }
    
    @objc dynamic var shouldSync: Bool = false
    
    @objc dynamic var startTime: String = ""
    @objc dynamic var endTime: String = ""
    @objc dynamic var boatsInspected: Bool = false
    @objc dynamic var motorizedBlowBys: Int = 0
    @objc dynamic var nonMotorizedBlowBys: Int = 0
    @objc dynamic var k9OnShif: Bool = false
    
    @objc dynamic var sunny: Bool = false
    @objc dynamic var cloudy: Bool = false
    @objc dynamic var raining: Bool = false
    @objc dynamic var snowing: Bool = false
    @objc dynamic var foggy: Bool = false
    @objc dynamic var windy: Bool = false
    
    @objc dynamic var date: Date?
    ///
    @objc dynamic var station: String = " "
    @objc dynamic var location: String = " "
    ///
    @objc dynamic var shitStartComments: String = ""
    @objc dynamic var shitEndComments: String = ""
    
    var inspections: List<WatercradftInspectionModel> = List<WatercradftInspectionModel>()
    
    
    @objc dynamic var status: String = "Pending Sync"
    // used for quary purposes (and displaying)
    @objc dynamic var formattedDate: String = ""
    
    func toDictionary() -> [String : Any] {
        return [
            "startTime": startTime,
            "endTime": endTime,
            "boatsInspected": boatsInspected,
            "motorizedBlowBys": motorizedBlowBys,
            "nonMotorizedBlowBys": nonMotorizedBlowBys,
            "k9OnShif": k9OnShif,
            "sunny": sunny,
            "cloudy": cloudy,
            "raining": raining,
            "snowing": snowing,
            "foggy": foggy,
            "windy": windy,
            "station": station,
            "shitStartComments": shitStartComments,
            "shitEndComments": shitEndComments,
        ]
    }
    
    func save() {
        RealmRequests.saveObject(object: self)
    }
    
    func set(value: Any, for key: String) {
        if self[key] == nil {
            print("\(key) is nil")
            return
        }
        do {
            let realm = try Realm()
            try realm.write {
                self[key] = value
            }
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
        }
    }
    
    func addInspection() -> WatercradftInspectionModel? {
        let inspection = WatercradftInspectionModel()
        inspection.shouldSync = false
        do {
            let realm = try Realm()
            try realm.write {
                self.inspections.append(inspection)
            }
            return inspection
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
            return nil
        }
    }
    
    func setShouldSync(to should: Bool) {
        
        do {
            let realm = try Realm()
            try realm.write {
                self.shouldSync = should
            }
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
        }
        if shouldSync == true {
            set(value: "Pending Sync", for: "status")
        } else {
            set(value: "Draft", for: "status")
        }
    }
    
    func setDate(to newDate: Date) {
        do {
            let realm = try Realm()
            try realm.write {
                self.date = newDate
            }
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
        }
        if let unwrappedDate = date {
            set(value: unwrappedDate.stringShort(), for: "formattedDate")
        }
    }
    
    // MARK: UI Helpers
    func getShiftStartFields(forModal: Bool, editable: Bool) -> [InputItem] {
        return ShiftFormHelper.getShiftStartFields(for: self, editable: editable, modalSize: forModal)
    }
    
    func getShiftEndFields(editable: Bool) -> [InputItem] {
        return ShiftFormHelper.getShiftEndFields(for: self, editable: editable)
    }
}
