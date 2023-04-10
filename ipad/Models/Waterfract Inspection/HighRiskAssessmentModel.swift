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
//    case Inspection
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
    @objc dynamic var standingWaterLocation1: String = ""
    @objc dynamic var standingWaterLocation2: String = ""
    @objc dynamic var standingWaterLocation3: String = ""
        
    @objc dynamic var adultDreissenidMusselsFound: Bool = false
    @objc dynamic var adultDreissenidMusselsLocation: String = ""
    @objc dynamic var adultDreissenidMusselsLocation1: String = ""
    @objc dynamic var adultDreissenidMusselsLocation2: String = ""
    @objc dynamic var adultDreissenidMusselsLocation3: String = ""
    
    @objc dynamic var decontaminationPerformed: Bool = false
    @objc dynamic var decontaminationReference: String = ""
    
    @objc dynamic var decontaminationOrderIssued: Bool = false
    @objc dynamic var decontaminationAppendixB: Bool = false
    @objc dynamic var decontaminationOrderNumber: Int = 0
    @objc dynamic var decontaminationOrderReason: String = ""
    
    @objc dynamic var sealIssued: Bool = false
    @objc dynamic var sealNumber: Int = 0
    
    @objc dynamic var dreissenidMusselsFoundPrevious: Bool = false;

    // General Comments
    @objc dynamic var generalComments: String = ""
    
    // Validators
    var validatorNames = ["decontaminationAppendixB",
                          "decontaminationPerformed",
                          "quarantinePeriodIssued",
                          "decontaminationOrderIssued",
                          "sealIssued"]
    @objc dynamic var decontaminationAppendixBInteracted = false
    @objc dynamic var decontaminationPerformedInteracted = false
    @objc dynamic var quarantinePeriodIssuedInteracted = false
    @objc dynamic var decontaminationOrderIssuedInteracted = false
    @objc dynamic var sealIssuedInteracted = false
    
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
        // Validation checks - check if this key requires interaction validation
        if validatorNames.contains(key) {
            setInteractedBool(validationName:"\(key)Interacted")
        }
    }
    
    // Validation check - if interacted with, set to true
    func setInteractedBool(validationName: String) {
        do {
            let realm = try Realm()
            try realm.write {
                self[validationName] = true
            }
        } catch let error as NSError {
            print("Error with finding validation")
            print(error)
        }
    }
    
    // MARK: - To Dictionary
    func toDictionary() -> [String: Any] {
        
        // Original data capture
        let standingWaterLocationId = Storage.shared.codeId(type: .adultMusselsLocation, name: standingWaterLocation)
        let adultDreissenidMusselsLocationId = Storage.shared.codeId(type: .adultMusselsLocation, name: adultDreissenidMusselsLocation)
        
        // Capture other location data
        let standingWaterLocationIds = [
            Storage.shared.codeId(type: .adultMusselsLocation, name: standingWaterLocation1),
            Storage.shared.codeId(type: .adultMusselsLocation, name: standingWaterLocation2),
            Storage.shared.codeId(type: .adultMusselsLocation, name: standingWaterLocation3)
        ]
        let adultDreissenidMusselsLocationIds = [
            Storage.shared.codeId(type: .adultMusselsLocation, name: adultDreissenidMusselsLocation1),
            Storage.shared.codeId(type: .adultMusselsLocation, name: adultDreissenidMusselsLocation2),
            Storage.shared.codeId(type: .adultMusselsLocation, name: adultDreissenidMusselsLocation3)
        ]
        
        var body: [String: Any] = [
            "cleanDrainDryAfterInspection": cleanDrainDryAfterInspection,
            "quarantinePeriodIssued": quarantinePeriodIssued,
            "standingWaterPresent": standingWaterPresent,
            "adultDreissenidaeMusselFound": adultDreissenidMusselsFound,
            "dreissenidMusselsFoundPrevious": dreissenidMusselsFoundPrevious,
            "decontaminationPerformed": decontaminationPerformed,
            "decontaminationOrderIssued": decontaminationOrderIssued,
            "decontaminationAppendixB": decontaminationAppendixB,
            "sealIssued": sealIssued,
            "watercraftRegistration": watercraftRegistration.count > 1 ? watercraftRegistration : "None",
            "decontaminationReference": decontaminationReference.count > 1 ? decontaminationReference : "None",
            "decontaminationOrderNumber": decontaminationOrderNumber > 0 ? decontaminationOrderNumber : -1,
            "decontaminationOrderReason": decontaminationOrderReason.count > 1 ? decontaminationOrderReason : "None",
            "sealNumber": sealNumber > 0 ? sealNumber : -1,
            "otherInspectionFindings": otherInspectionFindings.count > 1 ? otherInspectionFindings : "None",
            "generalComments": generalComments.count > 1 ? generalComments : "None",
        ]
        
        // Original data
        if let _standingWaterLocationId = standingWaterLocationId, standingWaterPresent {
            body["standingWaterLocation"] = _standingWaterLocationId
        }
        if let _adultDreissenidMusselsLocationId = adultDreissenidMusselsLocationId, adultDreissenidMusselsFound {
            body["adultDreissenidaeMusselDetail"] = _adultDreissenidMusselsLocationId
        }
        
        // Capture and add other location data
        for (index, id) in standingWaterLocationIds.enumerated() {
            if let id = id, standingWaterPresent {
                body["standingWaterLocation\(index + 1)"] = id
            }
        }
        for (index, id) in adultDreissenidMusselsLocationIds.enumerated() {
            if let id = id, adultDreissenidMusselsFound {
                body["adultDreissenidaeMusselDetail\(index + 1)"] = id
            }
        }
        
        return body
    }
    
    // MARK: UI Helpers
    func getInputputFields(for section: HighRiskFormSection, editable: Bool? = nil) -> [InputItem] {
        switch section {
        case .BasicInformation:
            return HighRiskFormHelper.getBasicInfoFields(for: self, editable: editable)
//        case .Inspection:
//            return HighRiskFormHelper.getInspectionFields(for: self, editable: editable)
        case .InspectionOutcomes:
            return HighRiskFormHelper.getInspectionOutcomesFields(for: self, editable: editable)
        }
    }
}
