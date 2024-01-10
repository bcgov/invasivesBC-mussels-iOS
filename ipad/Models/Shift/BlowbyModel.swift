//
//  BlowbyModel.swift
//  ipad
//
//  Created by Sustainment Team on 2024-01-02.
//  Copyright © Sustainment Team. All rights reserved.
//

import Foundation

import Realm
import RealmSwift

/// Model for displaying Blowbys that occur during a shift, complies with Realm protocols
class BlowbyModel: Object, BaseRealmObject {
    @objc dynamic var userId: String = ""
    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    override class func primaryKey() -> String? {
        return "localId"
    }

    @objc dynamic var remoteId: Int = -1
    @objc dynamic var shouldSync: Bool = true

    @objc dynamic var date: Date = Date()
    @objc dynamic var timeStamp: String = ""
    
    @objc dynamic var blowByTime: String = ""
    @objc dynamic var watercraftComplexity: String = ""
    @objc dynamic var reportedToRapp: Bool = false
    @objc dynamic var formattedReporttoRapp: String = "No"

    // MARK: Setters
  
  /// Setter method for BlowbyModel, used when new Blowbys are created, as they are not Realm objects
  /// - Parameters:
  ///   - value: value to change Models key to
  ///   - key: Text representation of the key to be changed in the model
    func set(value: Any, for key: String) {
        if self[key] == nil {
            print("\(key) is nil")
            return
        }
          self[key] = value
      if key == "reportedToRapp" {
        if let reported = value as? Bool {
          formattedReporttoRapp = reported ? "Yes" : "No";
        }
      }
    }
  
  /// Setter method for BlowbyModel, used when editing a new Blowby, since Realm objects must be edited in a write transaction
  /// - Parameters:
  ///   - value: Value to change Models key to
  ///   - key: Text representation of the key to be changed in the model
  func editSet(value: Any, for key: String) {
    do {
      let realm = try Realm()
      try realm.write {
          self[key] = value;
          if key == "reportedToRapp" {
            if let reported = value as? Bool {
              formattedReporttoRapp = reported ? "Yes" : "No";
            }
          }
        }
    } catch let error as NSError {
      print("** REALM ERROR")
      print(error)
    }
  }
  
  /// Function for setting RemoteID of Object managed by Realm
  /// - Parameter remoteId: remoteID Integer
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
  
  /// Returns Blowby fields set to this instance of object
  /// - Parameters:
  ///   - editable: Boolean for determining if values can be edited, or remain static
  ///   - modalSize: Boolean to determine if Large or small size of input fields are returned
  /// - Returns: Array of InputItems tailored to this model instance
    func getThisBlowbyFields(editable: Bool, modalSize: Bool) -> [InputItem] {
      return BlowByFormHelper.getBlowByFields(for: self, editable: editable, modalSize: modalSize)
    }
  
  /// Creates a formatted Date time object for displaying Blowby Data
  /// - Parameters:
  ///   - time: Value from the TimeInput field
  ///   - date: Value from the Date Input field
  /// - Returns: Date object taking the calendar date from date object, and time value from time String
    func formattedDateTime(time: String, date: Date) -> String? {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        timeFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let startDate = date
        let startTimeSplit = time.components(separatedBy: ":")
        guard let timeInDate = startDate.setTime(hour: Int(startTimeSplit[0]) ?? 0, min: Int(startTimeSplit[1]) ?? 0, sec: 1) else {
            return nil
        }
        
        return timeFormatter.string(from: timeInDate)
    }
    
    // MARK: - To Dictionary
    func toDictionary() -> [String : Any] {
        return toDictionary(shift: -1)
    }

    func toDictionary(shift id: Int) -> [String : Any] {
        let date = self.date
        guard let blowByTimeFormatted = formattedDateTime(time: timeStamp, date: date) else {
            return [String : Any]()
        }

        let body: [String: Any] = [
            "observerWorkflowId": id,
            "blowByTime": blowByTimeFormatted,
            "watercraftComplexity": watercraftComplexity,
            "reportedToRapp": reportedToRapp
        ]

        return body
    }
}
