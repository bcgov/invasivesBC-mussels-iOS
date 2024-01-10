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

/// Enum representing status of ShiftModel item
enum SyncableItemStatus {
    case Draft
    case PendingSync
    case Completed
}

/// Represents a shift model for tracking inspection details and shift information.
///
/// This class conforms to the Realm `Object` protocol and includes properties
/// for tracking shift details, inspections, and synchronization status.
class ShiftModel: Object, BaseRealmObject {
    @objc dynamic var userId: String = ""
    @objc dynamic var localId: String = { return UUID().uuidString }()
    override class func primaryKey() -> String? { return "localId" }
    @objc dynamic var remoteId: Int = -1
    @objc dynamic var shouldSync: Bool = false
    @objc dynamic var startTime: String = ""
    @objc dynamic var endTime: String = ""
    @objc dynamic var shiftStartDate: Date = Calendar.current.startOfDay(for: Date())
    @objc dynamic var boatsInspected: Bool = true
    @objc dynamic var motorizedBlowBys: Int = 0
    @objc dynamic var nonMotorizedBlowBys: Int = 0
    @objc dynamic var k9OnShif: Bool = false
    @objc dynamic var station: String = ""
    @objc dynamic var shitStartComments: String = ""
    @objc dynamic var shitEndComments: String = ""
    var inspections: List<WatercraftInspectionModel> = List<WatercraftInspectionModel>()
    @objc dynamic var status: String = "Draft"
    // used for query purposes (and displaying)
    @objc dynamic var formattedDate: String = ""

    /// Takes the Date of one Date object and combines it with the Time from another date object
    /// - Parameters:
    ///     - targetDate: The date to be captured in the new Date object
    ///     - targetTime: The time to be captured in the new Date object
    ///  - Returns: New Date object with merged Date and Time
    func combineDateWithCurrentTime(targetDate: Date, targetTime: Date) -> Date {
        let currentDate = targetTime

        // Extract time components from the current date
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: currentDate)

        // Set the time components to the existing date
        var combinedDateComponents = calendar.dateComponents([.year, .month, .day], from: targetDate)
        combinedDateComponents.hour = timeComponents.hour
        combinedDateComponents.minute = timeComponents.minute
        combinedDateComponents.second = timeComponents.second

        // Create a new Date object with the combined components
        return calendar.date(from: combinedDateComponents) ?? targetDate
    }
    // MARK: Save Object
    func save() {
        RealmRequests.saveObject(object: self)
    }
    
    // MARK: Add Inspection object
    func addInspection() -> WatercraftInspectionModel? {
        let inspection = WatercraftInspectionModel()
        inspection.shouldSync = false
        inspection.userId = self.userId
        inspection.timeStamp = combineDateWithCurrentTime(targetDate: shiftStartDate, targetTime: Date())
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
    /// Iterates through all stored inspections and updates them to the date reflected in the Shift
    /// - Parameters
    ///     - newDate: The date the inspections will be updated to
    func updateInspectionTimeStamps(newDate: Date) {
        do {
            let realm = try Realm()
            try realm.write {
                for inspection in self.inspections {
                    inspection.timeStamp = combineDateWithCurrentTime(targetDate: newDate, targetTime: inspection.timeStamp)
                }
            }
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
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
            if(key == "shiftStartDate"){
                try realm.write {
                    self.formattedDate = shiftStartDate.stringShort()
                }
                updateInspectionTimeStamps(newDate: shiftStartDate);
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
    /// Formats a Date object with a Time String into a readable format
    /// - Parameters:
    ///     - time: String object representing time "10:42"
    ///     - date: Date object representing given day
    /// - Returns: Formatted date string YYYY-MM-DD hh:mm:ss
    func formattedDateTime(time: String, date: Date) -> String? {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "YYYY-MM-dd hh:mm:ss"
        let startDate = shiftStartDate
        let startTimeSplit = time.components(separatedBy: ":")
        guard let timeInDate = startDate.setTime(hour: Int(startTimeSplit[0]) ?? 0, min: Int(startTimeSplit[1]) ?? 0, sec: 1) else {
            return nil
        }
        return timeFormatter.string(from: timeInDate)
    }
    // MARK: To Dictionary
    func toDictionary() -> [String : Any] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let formattedDateFull = dateFormatter.string(from: shiftStartDate)
        
        guard let startTimeFormatted = formattedDateTime(time: startTime, date: shiftStartDate), let endTimeFormatted = formattedDateTime(time: endTime, date: shiftStartDate) else {
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
            "motorizedBlowBys": motorizedBlowBys,
            "nonMotorizedBlowBys": nonMotorizedBlowBys,
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
