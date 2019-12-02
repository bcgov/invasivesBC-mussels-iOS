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

class WatercradftInspectionModel: Object, BaseRealmObject {
    @objc dynamic var userId: String = ""
    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()
    
    override class func primaryKey() -> String? {
        return "localId"
    }
    
    @objc dynamic var remoteId: Int = -1 {
        didSet {
            if remoteId > 0 {
                set(value: "Completed", for: "status")
            }
        }
    }
    
    @objc dynamic var shouldSync: Bool = false {
        didSet {
            if shouldSync == true {
                set(value: "Pending Sync", for: "status")
            } else {
                set(value: "Draft", for: "status")
            }
        }
    }
    
    // PASSPORT INFO
    @objc dynamic var isPassportHolder: Bool = false
    @objc dynamic var inspectionTime: String = ""
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
    @objc dynamic var commerciallyHauled: Bool = false
    @objc dynamic var highRiskArea: Bool = false
    @objc dynamic var previousAISKnowlede: Bool = false
    @objc dynamic var previousAISKnowledeSource: String = ""
    @objc dynamic var previousInspection: Bool = false
    @objc dynamic var previousInspectionSource: String = ""
    @objc dynamic var previousInspectionDays: Int = 0
    
    // Inspection Details
    @objc dynamic var marineMusslesFound: Bool = false
    @objc dynamic var failedToStop: Bool = false
    @objc dynamic var ticketIssued: Bool = false
    
    // High Risk Assesment fields
    @objc dynamic var highriskAIS: Bool = false {
        didSet {
            if highriskAIS == true {
                set(value: "High", for: "riskLevel")
            } else {
                set(value: "Low", for: "riskLevel")
            }
        }
    }
    @objc dynamic var adultDreissenidFound: Bool = false
    
    // General comments
    @objc dynamic var generalComments: String = ""
    
    // Journey
    private var journeyDetails: List<JourneyDetailsModel> = List<JourneyDetailsModel>()
    @objc dynamic var previousWaterBodies: [[String: Any]] =  [[String: Any]]()
    @objc dynamic var destinationWaterBodies: [[String: Any]] =  [[String: Any]]()
    
    // High Risk Assessments
    private var highRiskAssessments: List<HighRiskAssessmentModel> = List<HighRiskAssessmentModel>()
    
    // Form Objects (Cached - Not stored)
    private var inputItems : [WatercraftFromSection: [InputItem]] = [WatercraftFromSection: [InputItem]]()
    
    @objc dynamic var status: String = "Pending Sync"
    
    @objc dynamic var riskLevel: String = "low"
    
    func toDictionary() -> [String : Any] {
        return toDictionary(shift: -1)
    }
    
    func toDictionary(shift id: Int) -> [String : Any] {
        // TODO: REMOVE THIS FROM API - its only here because api requires it
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let tempDateToDelete = dateFormatter.string(from: Date())
        ///
        
        // Create dictionary for high-risk assessment
        var highRiskAssessmentForm: [String: Any] = [String: Any] ()
        if let highRiskAssessment = self.highRiskAssessments.first {
            highRiskAssessmentForm = highRiskAssessment.toDictionary()
        }
        return [
            "lowRiskAssessmentForm": [:], // TODO: Remove from API
            "additionalInfo": [:], // TODO: Remove from API
            "timestamp": tempDateToDelete, // TODO: Remove from API
            
            "workflow": id,
            "highRiskAssessmentForm": highRiskAssessmentForm,
            "fullObservationForm": [
                "isPassportHolder": isPassportHolder,
                "inspectionTime": inspectionTime,
                "passportNumber": passportNumber,
                "launchedOutsideBC": launchedOutsideBC,
                "k9Inspection": k9Inspection,
                "decontaminationPerformed": decontaminationPerformed,
                "marineSpeciesFound": marineSpeciesFound,
                "aquaticPlantsFound": aquaticPlantsFound,
                
                "province": province,
                "nonMotorized": province,
                "simple": simple,
                "complex": complex,
                "veryComplex": veryComplex,
                
                "numberOfPeopleInParty": numberOfPeopleInParty,
                "commerciallyHauled": commerciallyHauled,
                "highRiskArea": highRiskArea,
                "previousAISKnowlede": previousAISKnowlede,
                "previousAISKnowledeSource": previousAISKnowledeSource,
                "previousInspection": previousInspection,
                "previousInspectionSource": previousInspectionSource,
                "previousInspectionDays": previousInspectionDays,
                
                "marineMusslesFound": marineMusslesFound,
                "failedToStop": marineMusslesFound,
                "ticketIssued": marineMusslesFound,
                
                "highriskAIS": highriskAIS,
                "adultDreissenidFound": adultDreissenidFound,
                
                "generalComments": generalComments
            ]
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
    
    func setRemote(id: Int) {
        do {
            let realm = try Realm()
            try realm.write {
                self.remoteId = id
            }
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
        }
    }
    
    func addHighRiskAssessment() -> HighRiskAssessmentModel? {
        if let existing = self.highRiskAssessments.first {
            return existing
        }
        let assessment = HighRiskAssessmentModel()
        assessment.shouldSync = false
        assessment.userId = self.userId
        do {
            let realm = try Realm()
            try realm.write {
                self.highRiskAssessments.append(assessment)
            }
            return assessment
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
            return nil
        }
    }
    
    /*
     Edit journey details arrays Based on input item key
     Input item key would be something like
        previousWaterBody-waterbody-0
        Journey detail type - field key - index of journey detail type
     */
    func editJourney(inputItemKey: String, value: Any) {
        if inputItemKey.contains("previousWaterBody") {
            // Previous Water Body
            let splitKey = inputItemKey.split(separator: "-")
            guard let index = Int(splitKey[2]) else {return}
            let key = String(splitKey[1])
            if self.previousWaterBodies.count - 1 >= index {
              // Index Exists
               do {
                   let realm = try Realm()
                   try realm.write {
                        self.previousWaterBodies[index][key] = value
                   }
                   
               } catch let error as NSError {
                   print("** REALM ERROR")
                   print(error)
               }
            } else {
                // Index Doesnt exist
                do {
                    let realm = try Realm()
                    try realm.write {
                         self.previousWaterBodies.append([key : value])
                    }
                    
                } catch let error as NSError {
                    print("** REALM ERROR")
                    print(error)
                }
            }
        } else if inputItemKey.contains("destinationWaterBody") {
            // Destination Water Body
            let splitKey = inputItemKey.split(separator: "-")
            guard let index = Int(splitKey[2]) else {return}
            let key = String(splitKey[1])
            if self.destinationWaterBodies.count - 1 >= index {
                // Index Exists
                do {
                    let realm = try Realm()
                    try realm.write {
                         self.destinationWaterBodies[index][key] = value
                    }
                    
                } catch let error as NSError {
                    print("** REALM ERROR")
                    print(error)
                }
            } else {
                // Index Doesnt exist
                do {
                    let realm = try Realm()
                    try realm.write {
                        self.destinationWaterBodies.append([key : value])
                    }
                    
                } catch let error as NSError {
                    print("** REALM ERROR")
                    print(error)
                }
            }
        } else {
            return
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
