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

enum SyncableItemStatus {
    case Draft
    case PendingSync
    case Completed
}

class ShiftModel: Object, BaseRealmObject {
    @objc dynamic var userId: String = ""
    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()
    
    override class func primaryKey() -> String? {
        return "localId"
    }
    
    @objc dynamic var remoteId: Int = -1
    
    @objc dynamic var shouldSync: Bool = false
    
    @objc dynamic var startTime: String = ""
    @objc dynamic var endTime: String = ""
    @objc dynamic var boatsInspected: Bool = true
    @objc dynamic var k9OnShif: Bool = false
    @objc dynamic var date: Date?
    @objc dynamic var station: String = ""
//    @objc dynamic var location: String = " "
    ///
    @objc dynamic var shitStartComments: String = ""
    @objc dynamic var shitEndComments: String = ""
    
    var inspections: List<WatercraftInspectionModel> = List<WatercraftInspectionModel>()
    
    var blowBys: List<BlowByModel> = List<BlowByModel>()
    
    @objc dynamic var status: String = "Draft"
    // used for quary purposes (and displaying)
    @objc dynamic var formattedDate: String = ""
    
    // MARK: Save Object
    func save() {
        RealmRequests.saveObject(object: self)
    }
    
    // MARK: Add Inspection object
    func addInspection() -> WatercraftInspectionModel? {
        let inspection = WatercraftInspectionModel()
        inspection.shouldSync = false
        inspection.userId = self.userId
        inspection.timeStamp = Date()
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
    
    // MARK: Add Blow By object
    func addblowBy() -> BlowByModel? {
        let blowBy = BlowByModel()
        blowBy.shouldSync = false
        blowBy.userId = self.userId
        blowBy.timeStamp = Date()
        do {
            let realm = try Realm()
            try realm.write {
                self.blowBys.append(blowBy)
            }
            return blowBy
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
            return nil
        }
    }
    
    // MARK: Setters
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
    
    func set(shouldSync should: Bool) {
        set(status: should ? .PendingSync : .Draft )
        do {
            let realm = try Realm()
            try realm.write {
                self.shouldSync = should
                self.status = should ? "Pending Sync" : "Draft"
            }
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
        }
    }
    
    func set(status statusEnum: SyncableItemStatus) {
        var newStatus = "\(statusEnum)"
        switch statusEnum {
        case .Draft:
            newStatus = "Draft"
        case .PendingSync:
            newStatus = "Pending Sync"
        case .Completed:
            newStatus = "Completed"
        }
        do {
            let realm = try Realm()
            try realm.write {
                self.status = newStatus
            }
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
        }
    }
    
    func set(date newDate: Date) {
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
    
    func set(remoteId: Int) {
        do {
            let realm = try Realm()
            try realm.write {
                self.remoteId = remoteId
            }
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
        }
    }
    
    // MARK: Getters
    func getStatus() -> SyncableItemStatus {
        switch self.status.lowercased() {
        case "draft":
            return .Draft
        case "pending sync":
            return .PendingSync
        case "completed":
            return .Completed
        default:
            return .Draft
        }
    }
    
    func formattedDateTime(time: String, date: Date) -> String? {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "YYYY-MM-dd hh:mm:ss"
        let startDate = date
        let startTimeSplit = time.components(separatedBy: ":")
        guard let timeInDate = startDate.setTime(hour: Int(startTimeSplit[0]) ?? 0, min: Int(startTimeSplit[1]) ?? 0, sec: 1) else {
            return nil
        }
        
        return timeFormatter.string(from: timeInDate)
    }
    
    // MARK: To Dictionary
    func toDictionary() -> [String : Any] {
        guard let date = date else {return [String : Any]()}
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let formattedDateFull = dateFormatter.string(from: date)
        
        guard let startTimeFormatted = formattedDateTime(time: startTime, date: date), let endTimeFormatted = formattedDateTime(time: endTime, date: date) else {
            return [String : Any]()
        }
        
        return [
            "date": formattedDateFull,
            "startTime": startTimeFormatted,
            "endTime": endTimeFormatted,
            "station": station,
            "location": "NA",
            "shiftStartComment": shitStartComments.count > 1 ? shitStartComments : "None",
            "shiftEndComment":  shitEndComments.count > 1 ? shitEndComments : "None",
            "boatsInspected": boatsInspected,
            "k9OnShift": k9OnShif
        ]
    }
    
    // MARK: UI Helpers
    func getShiftStartFields(forModal: Bool, editable: Bool) -> [InputItem] {
        return ShiftFormHelper.getShiftStartFields(for: self, editable: editable, modalSize: forModal)
    }
    
    func getShiftEndFields(editable: Bool) -> [InputItem] {
        return ShiftFormHelper.getShiftEndFields(for: self, editable: editable)
    }
}
