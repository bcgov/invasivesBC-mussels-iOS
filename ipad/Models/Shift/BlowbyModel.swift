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

    @objc dynamic var timeStamp: Date = Date()

    @objc dynamic var shiftId: String = ""
    @objc dynamic var blowByTime: String = ""
    @objc dynamic var watercraftComplexity: String = ""
    @objc dynamic var reportedToRapp: Bool = false

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

    // MARK: - To Dictionary
    func toDictionary() -> [String : Any] {
        return toDictionary(shift: -1)
    }

    func toDictionary(shift id: Int) -> [String : Any] {

        let body: [String: Any] = [
            "observerWorkflowId": id,
            "blowByTime": blowByTime,
            "watercraftComplexity": watercraftComplexity,
            "reportedToRapp": reportedToRapp
        ]

        return body
    }
}
