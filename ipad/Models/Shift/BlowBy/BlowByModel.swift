//
//  BlowByModel.swift
//  ipad
//
//  Created by Sustainment Team on 2019-11-12.
//  Copyright © 2019 Sustainment Team. All rights reserved.
//

import Foundation

import Realm
import RealmSwift

class BlowByModel: Object, BaseRealmObject {
    @objc dynamic var userId: String = ""
    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()
    
    override class func primaryKey() -> String? {
        return "localId"
    }
    
    @objc dynamic var timeStamp: Date = Date()
    
    @objc dynamic var remoteId: Int = -1
    @objc dynamic var shouldSync: Bool = false
    
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
    
    // MARK: - To Dictionary
    func toDictionary() -> [String: Any] {
        
        var body: [String: Any] = [
            "blowByTime": blowByTime,
            "watercraftComplexity": watercraftComplexity,
            "reportedToRapp": reportedToRapp
        ]
        
        return body
    }
    
    // MARK: UI Helpers
//    func getInputputFields(for section: HighRiskFormSection, editable: Bool? = nil) -> [InputItem] {
//        switch section {
//        case .BasicInformation:
//            return HighRiskFormHelper.getBasicInfoFields(for: self, editable: editable)
////        case .Inspection:
////            return HighRiskFormHelper.getInspectionFields(for: self, editable: editable)
//        case .InspectionOutcomes:
//            return HighRiskFormHelper.getInspectionOutcomesFields(for: self, editable: editable)
//        }
//    }
}
