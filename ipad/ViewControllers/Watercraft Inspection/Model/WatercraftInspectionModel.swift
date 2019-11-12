//
//  WatercraftInspectionModel.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-11.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation

import Realm
import RealmSwift

protocol PropertyReflectable { }

extension PropertyReflectable {
    subscript(key: String) -> Any? {
        let m = Mirror(reflecting: self)
        return m.children.first { $0.label == key }?.value
    }
}

extension WatercradftInspectionModel : PropertyReflectable {}

class WatercradftInspectionModel: Object, BaseRealmObject {
    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()
    
    override class func primaryKey() -> String? {
        return "localId"
    }
    
    @objc dynamic var remoteId: Int = -1
    
    @objc dynamic var shouldSync: Bool = false
    
    // PASSPORT INFO
    @objc dynamic var isPassportHolder: Bool = false
    @objc dynamic var inspectionTime: Double = 0
    @objc dynamic var passportNumber: String = ""
    @objc dynamic var launchedOutsideBC : Bool = false
    @objc dynamic var k9Inspection: Bool = false
    @objc dynamic var decontaminationPerformed: Bool = false
    @objc dynamic var marineSpeciesFound: Bool = false
    @objc dynamic var aquaticPlantsFound: Bool = false
    // Full Inspection
    // Basic
    @objc dynamic var province: String = ""
    @objc dynamic var nonMotorized: Int = 0
    @objc dynamic var simple: Int = 0
    @objc dynamic var complex: Int = 0
    @objc dynamic var veryComplex: Int = 0
    // Watercraft Details
    @objc dynamic var numberOfPeopleInParty: Int = 0
    @objc dynamic var commerciallyHauled: Int = 0
    @objc dynamic var highRiskArea: Bool = false
    @objc dynamic var previousAISKnowlede: Bool = false
    @objc dynamic var previousAISKnowledeSource: String = ""
    @objc dynamic var previousInspection: Bool = false
    @objc dynamic var previousInspectionSource: String = ""
    @objc dynamic var previousInspectionDays: Int = 0
    //
    // Inspection Details
    @objc dynamic var marineMusslesFound: Bool = false
    @objc dynamic var failedToStop: Bool = false
    @objc dynamic var ticketIssued: Bool = false
    // High Risk Assesment fields
    @objc dynamic var highriskAIS: Bool = false
    @objc dynamic var adultDreissenidFound: Bool = false
    // General comments
    @objc dynamic var generalComments: String = ""
    // Journey
    private var journeyDetails: JourneyDetailsModel = JourneyDetailsModel()
    
    // Form Objects (Cached - Not stored)
    private var inputItems : [WatercraftFromSection: [InputItem]] = [WatercraftFromSection: [InputItem]]()
    
    func toDictionary() -> [String : Any] {
        return [
            "isPassportHolder": isPassportHolder,
            "inspectionTime": inspectionTime,
            "passportNumber": passportNumber,
            "launchedOutsideBC": launchedOutsideBC,
            "k9Inspection": k9Inspection,
            "decontaminationPerformed": decontaminationPerformed,
            "marineSpeciesFound": marineSpeciesFound,
            "aquaticPlantsFound": aquaticPlantsFound
        ]
    }
    
    func set(value: Any, for key: String) {
        if self[key] != nil {
            self[key] = value
        } else {
            print("\(key) is nil")
        }
    }
    
    func getInputputFields(for section: WatercraftFromSection, editable: Bool? = nil) -> [InputItem] {
        if let items = inputItems[section] {
            return items
        } else {
            switch section {
            case .PassportInfo:
                inputItems[section] = WatercraftInspectionFormHelper.getPassportFields(for: self, editable: editable)
                return inputItems[section] ?? []
            case .BasicInformation:
                inputItems[section] = WatercraftInspectionFormHelper.getBasicInfoFields(for: self, editable: editable)
                return inputItems[section] ?? []
            case .WatercraftDetails:
                inputItems[section] = WatercraftInspectionFormHelper.getWatercraftDetailsFields(for: self, editable: editable)
                return inputItems[section] ?? []
            case .JourneyDetails:
                inputItems[section] = WatercraftInspectionFormHelper.getPassportFields(for: self, editable: editable)
                return inputItems[section] ?? []
            case .InspectionDetails:
                inputItems[section] = WatercraftInspectionFormHelper.getInspectionDetailsFields(for: self, editable: editable)
                return inputItems[section] ?? []
            case .GeneralComments:
                inputItems[section] = WatercraftInspectionFormHelper.getGeneralCommentsFields(for: self, editable: editable)
                return inputItems[section] ?? []
            case .HighRiskAssessmentFields:
                inputItems[section] = WatercraftInspectionFormHelper.getHighriskAssessmentFieldsFields(for: self, editable: editable)
                return inputItems[section] ?? []
            case .Divider:
                return []
            }
        }
    }
}
