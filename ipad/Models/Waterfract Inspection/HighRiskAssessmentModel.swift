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

public enum HighRiskFormSection: Int, CaseIterable {
    case BasicInformation = 0
    case Inspection
    case InspectionOutcomes
}


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
    @objc dynamic var watercraftRegistration: String = ""
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
    @objc dynamic var decontaminationReference: String = ""
    
    @objc dynamic var decontaminationOrderIssued: Bool = false
    @objc dynamic var decontaminationOrderNumber: Int = 0
    
    @objc dynamic var sealIssued: Bool = false
    @objc dynamic var sealNumber: Int = 0
    // General Comments
    @objc dynamic var generalComments: String = ""
    
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
    
    // MARK: To Dictionary
    func toDictionary() -> [String : Any] {
        
        let standingWaterLocationId = Storage.shared.codeId(type: .adultMusselsLocation, name: standingWaterLocation)
        let adultDreissenidMusselsLocationId = Storage.shared.codeId(type: .adultMusselsLocation, name: adultDreissenidMusselsLocation)
        var body: [String : Any] = [
            "cleanDrainDryAfterInspection": cleanDrainDryAfterInspection,
            "quarantinePeriodIssued": quarantinePeriodIssued,
            "standingWaterPresent": standingWaterPresent,
            "adultDreissenidaeMusselFound": adultDreissenidMusselsFound,
            "decontaminationPerformed": decontaminationPerformed,
            "decontaminationOrderIssued": decontaminationOrderIssued,
            "sealIssued": sealIssued,
            "watercraftRegistration": watercraftRegistration.count > 1 ? watercraftRegistration : "None",
            "decontaminationReference": decontaminationReference.count > 1 ? decontaminationReference : "None",
            "decontaminationOrderNumber": decontaminationOrderNumber > 0 ? decontaminationOrderNumber : -1,
            "sealNumber": sealNumber > 0 ? sealNumber : -1,
            "otherInspectionFindings": otherInspectionFindings.count > 1 ? otherInspectionFindings : "None",
            "generalComments": generalComments.count > 1 ? generalComments : "None",
        ]
        
        if let _standingWaterLocationId = standingWaterLocationId, standingWaterPresent {
            body["standingWaterLocation"] = _standingWaterLocationId
        }
        
        if let _adultDreissenidMusselsLocationId = adultDreissenidMusselsLocationId, adultDreissenidMusselsFound {
            body["adultDreissenidaeMusselDetail"] = _adultDreissenidMusselsLocationId
        }
        
        return body
    }
    
    // MARK: UI Helpers
    func getInputputFields(for section: HighRiskFormSection, editable: Bool? = nil) -> [InputItem] {
        switch section {
        case .BasicInformation:
            return HighRiskFormHelper.getBasicInfoFields(for: self, editable: editable)
        case .Inspection:
            return HighRiskFormHelper.getInspectionFields(for: self, editable: editable)
        case .InspectionOutcomes:
            return HighRiskFormHelper.getInspectionOutcomesFields(for: self, editable: editable)
        }
    }
}
