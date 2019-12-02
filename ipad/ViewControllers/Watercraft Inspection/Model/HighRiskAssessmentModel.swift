//
//  HighRiskAssessmentModel.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-12.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation

import Realm
import RealmSwift

class HighRiskAssessmentModel: Object, BaseRealmObject {
    @objc dynamic var userId: String = ""
    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()
    
    override class func primaryKey() -> String? {
        return "localId"
    }
    
    @objc dynamic var remoteId: Int = -1
    @objc dynamic var shouldSync: Bool = false
    
    // Basic Info
    @objc dynamic var watercraftRegistration: Int = 0
    // Inspection
    @objc dynamic var cleanDrainDryAfterInspection: Bool = false
    // Inspection Outcomes
    @objc dynamic var otherInspectionFindings: String = ""
    @objc dynamic var quarantinePeriodIssued: Bool = false
    
    @objc dynamic var standingWaterPresent: Bool = false
    @objc dynamic var standingWaterLocation: String = ""
    
    @objc dynamic var adultDreissenidMusselsFound: Bool = false
    @objc dynamic var adultDreissenidMusselsLocation: String = ""
    
    @objc dynamic var decontaminationPerformed: Bool = false
    @objc dynamic var decontaminationReference: Int = 0
    
    @objc dynamic var decontaminationOrderIssued: Bool = false
    @objc dynamic var decontaminationOrderNumber: Int = 0
    
    @objc dynamic var sealIssued: Bool = false
    @objc dynamic var sealNumber: Int = 0
    // General Comments
    @objc dynamic var generalComments: String = ""
    
    // Form Objects (Cached - Not stored)
    private var inputItems : [HighRiskFormSection: [InputItem]] = [HighRiskFormSection: [InputItem]]()
    
    func toDictionary() -> [String : Any] {
        return [
            "watercraftRegistration": watercraftRegistration,
            "cleanDrainDryAfterInspection": cleanDrainDryAfterInspection,
            "otherInspectionFindings": otherInspectionFindings,
            "quarantinePeriodIssued": quarantinePeriodIssued,
            "standingWaterPresent": standingWaterPresent,
            "standingWaterLocation" : standingWaterLocation,
            "adultDreissenidMusselsFound": adultDreissenidMusselsFound,
            "adultDreissenidMusselsLocation": adultDreissenidMusselsLocation,
            "decontaminationPerformed": decontaminationPerformed,
            "decontaminationReference": decontaminationReference,
            "decontaminationOrderIssued": decontaminationOrderIssued,
            "decontaminationOrderNumber": decontaminationOrderNumber,
            "sealIssued": sealIssued,
            "sealNumber": sealNumber,
            "generalComments": generalComments
        ]
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
    
    func getInputputFields(for section: HighRiskFormSection, editable: Bool? = nil) -> [InputItem] {
        if let items = inputItems[section] {
            return items
        } else {
            switch section {
            case .BasicInformation:
                inputItems[section] = HighRiskFormHelper.getBasicInfoFields(for: self, editable: editable)
                return inputItems[section] ?? []
            case .Inspection:
                inputItems[section] = HighRiskFormHelper.getInspectionFields(for: self, editable: editable)
                return inputItems[section] ?? []
            case .InspectionOutcomes:
                inputItems[section] = HighRiskFormHelper.getInspectionOutcomesFields(for: self, editable: editable)
                return inputItems[section] ?? []
            case .GeneralComments:
                inputItems[section] = HighRiskFormHelper.getGeneralCommentsFields(for: self, editable: editable)
                return inputItems[section] ?? []
            }
        }
    }
}
