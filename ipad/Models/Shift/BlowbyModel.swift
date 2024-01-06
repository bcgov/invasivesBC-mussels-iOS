//
//  BlowbyModel.swift
//  ipad
//
//  Created by Matthew Logan on 2024-01-02.
//  Copyright © 2024 Amir Shayegh. All rights reserved.
//

import Foundation

import Realm
import RealmSwift

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

    // MARK: Setters
    func set(value: Any, for key: String) {
        if self[key] == nil {
            print("\(key) is nil")
            return
        }
          self[key] = value
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
    
    func getThisBlowbyFields(editable: Bool, modalSize: Bool) -> [InputItem] {
      return BlowByFormHelper.getBlowByFields(for: self, editable: editable, modalSize: modalSize)
    }
    
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
