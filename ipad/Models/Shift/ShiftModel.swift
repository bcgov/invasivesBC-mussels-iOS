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
    case Errors
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
    @objc dynamic var k9OnShif: Bool = false
    @objc dynamic var motorizedBlowBys: Int = 0
    @objc dynamic var nonMotorizedBlowBys: Int = 0
    @objc dynamic var station: String = ""
    @objc dynamic var stationComments: String = ""
    @objc dynamic var shiftStartComments: String = ""
    @objc dynamic var shiftEndComments: String = ""
    let BlowbyFields = ["reportedToRapp", "timeStamp", "watercraftComplexity"];
    var inspections: List<WatercraftInspectionModel> = List<WatercraftInspectionModel>()
    var blowbys: List<BlowbyModel> = List<BlowbyModel>()
    @objc dynamic var status: String = "Draft"
    // used for query purposes (and displaying)
    // used for query purposes (and displaying)
    @objc dynamic var formattedDate: String = Calendar.current.startOfDay(for: Date()).stringShort()


    private static let dateOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")!
        return formatter
    }()

    private static let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "UTC")!
        return formatter
    }()

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
  func updateBlowbyTimeStamps(newDate: Date) {
      do {
          let realm = try Realm()
          try realm.write {
              for blowby in self.blowbys {
                  blowby.date = combineDateWithCurrentTime(targetDate: newDate, targetTime: blowby.date)
                  _ = blowby.formattedDateTime(time: blowby.timeStamp,date: blowby.date)
              }
          }
      } catch let error as NSError {
          print("** REALM ERROR")
          print(error)
      }
  }
    
  func addBlowby(blowby: BlowbyModel) -> BlowbyModel? {
        blowby.shouldSync = true;
        blowby.userId = self.userId;
        do {
            let realm = try Realm();
            try realm.write {
                self.blowbys.append(blowby);
            }
            return blowby;
        } catch let error as NSError {
            print("** REALM ERROR");
            print(error);
            return nil;
        }
    }
    
    // MARK: Setters
    func set(value: Any, for key: String) {
      if BlowbyFields.contains(key){return}
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
                updateBlowbyTimeStamps(newDate: shiftStartDate)
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
        case .Errors:
            newStatus = "Contains Errors"
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
        case "contains errors":
            return .Errors
        default:
            return .Draft
        }
    }
    /// Formats a Date object with a Time String into a readable format
    /// - Parameters:
    ///     - time: String object representing time in "HH:mm" format (e.g. "10:42")
    ///     - date: Date object representing the target date
    /// - Returns: Formatted date string in "yyyy-MM-dd HH:mm:ss" format
    func formattedDateTime(time: String, date: Date) -> String? {
        let timeParts = time.components(separatedBy: ":")
        
        // Validate time format
        guard timeParts.count == 2,
              let hour = Int(timeParts[0]),
              let minute = Int(timeParts[1]),
              hour >= 0 && hour < 24,
              minute >= 0 && minute < 60 else {
            return nil
        }
        
        // Create a calendar in the station's timezone
        var calendar = Calendar.current
        calendar.timeZone = ShiftModel.getTimezoneForStation(self.station)
        
        // Create components in station's timezone
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = hour
        components.minute = minute
        components.second = 1
        
        guard let localDate = calendar.date(from: components) else {
            return nil
        }
        
        return ShiftModel.dateTimeFormatter.string(from: localDate)
    }
  
    func deleteBlowby(blowbyToDelete: BlowbyModel) -> Void {
        // Open a write transaction
        do {
            let realm = try Realm()
            try realm.write {
                // Delete the object from Realm
                realm.delete(blowbyToDelete)
            }
        }  catch {
            print("Error deleting blowby: \(error)")
        }
    }
  
    // MARK: To Dictionary
    func toDictionary() -> [String : Any] {
        let formattedDateFull = ShiftModel.dateOnlyFormatter.string(from: shiftStartDate)
        
        // Use the existing shiftDateFormatter for the full date-time
        guard let startTimeFormatted = formattedDateTime(time: startTime, date: shiftStartDate),
              let endTimeFormatted = formattedDateTime(time: endTime, date: shiftStartDate) else {
            return [String : Any]()
        }
        
        return [
            "date": formattedDateFull,
            "startTime": startTimeFormatted,
            "endTime": endTimeFormatted,
            "station": station,
            "location": "NA",
            "motorizedBlowBys": motorizedBlowBys,
            "nonMotorizedBlowBys": nonMotorizedBlowBys,
            "stationInformation": stationComments.count > 1 ? stationComments : "",
            "shiftStartComment": shiftStartComments.count > 1 ? shiftStartComments : "",
            "shiftEndComment":  shiftEndComments.count > 1 ? shiftEndComments : "",
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
  
  func getBlowbyFields(editable: Bool) -> [InputItem] {
    return BlowByFormHelper.getBlowByFields(for: BlowbyModel());
  }

  public static func stationRequired(_ station: String?) -> Bool {
    guard let station = station else { return false }
    let requiredStations = ["Other", "Project", "Emergency Response"]
    return requiredStations.contains(station)
  }

  private static func getTimezoneForStation(_ station: String) -> TimeZone {
    // Stations that observe Mountain Time with DST (MDT/MST)
    let mountainTimeDSTStations = [
        "Golden",
        "Olsen (Hwy 3)",
        "Cutts (Hwy 93)",
        "Cranbrook Roving - Scheduled Inspection",
        "Cranbrook Roving - Rykerts",
        "Cranbrook Roving - Nelway",
        "Cranbrook Roving - Waneta",
        "Cranbrook Roving - Patterson",
        "Cranbrook Roving - Outreach"
    ]
    
    // Stations that observe Mountain Time without DST (MST only)
    let mountainTimeNoDSTStations = [
        "Dawson Creek",
        "Yahk"
    ]
    
    if mountainTimeDSTStations.contains(station) {
        // America/Edmonton observes MDT/MST
        return TimeZone(identifier: "America/Edmonton") ?? TimeZone.current
    }
    
    if mountainTimeNoDSTStations.contains(station) {
        // America/Phoenix doesn't observe DST, staying on MST
        return TimeZone(identifier: "America/Phoenix") ?? TimeZone.current
    }
    
    // All other stations use Pacific Time (PST/PDT)
    // America/Vancouver observes PDT/PST
    return TimeZone(identifier: "America/Vancouver") ?? TimeZone.current
  }
}
