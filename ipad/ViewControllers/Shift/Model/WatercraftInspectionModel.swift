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
    
    @objc dynamic var remoteId: Int = -1
    
    @objc dynamic var shouldSync: Bool = false
    
    @objc dynamic var timeStamp: Date = Date()
    
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
    var previousWaterBodies: List<PreviousWaterbodyModel> = List<PreviousWaterbodyModel>()
    var destinationWaterBodies: List<DestinationWaterbodyModel> = List<DestinationWaterbodyModel>()
    
    // High Risk Assessments
    var highRiskAssessments: List<HighRiskAssessmentModel> = List<HighRiskAssessmentModel>()
    
    @objc dynamic var status: String = "Draft"
    
    @objc dynamic var riskLevel: String = "low"
    
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
    
    func set(shouldSync should: Bool) {
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
    
    // MARK: Getters
    func getStatus() -> SyncableItemStatus {
        switch self.status.lowercased() {
        case "draft":
            return .Draft
        case "pending sync":
            return .PendingSync
        case "completed":
            return .Completed
        default:
            return .Draft
        }
    }
    
    // MARK: To dictionary
    func toDictionary() -> [String : Any] {
        return toDictionary(shift: -1)
    }
    
    func toDictionary(shift id: Int) -> [String : Any] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD"
        let formattedDateFull = dateFormatter.string(from: self.timeStamp)
        
        // Create dictionary for high-risk assessment
        var highRiskAssessmentForm: [String: Any] = [String: Any] ()
        if let highRiskAssessment = self.highRiskAssessments.first {
            highRiskAssessmentForm = highRiskAssessment.toDictionary()
        }
        
        let journeysBody = getJourneyDetailsDictionary()

        var body: [String : Any] = [
            "workflow": id,
            "timestamp": formattedDateFull,
            "passportHolder": isPassportHolder,
            "k9Inspection": k9Inspection,
            "marineSpeciesFound": marineSpeciesFound,
            "aquaticPlantsFound": aquaticPlantsFound,
            "previousAISKnowledge": previousAISKnowlede,
            "previousInspection": previousInspection,
            "marineMusselFound": marineMusslesFound,
            "adultDreissenidaeFound": adultDreissenidFound,
            "nonMotorized": nonMotorized,
            "simple": simple,
            "complex": complex,
            "veryComplex": veryComplex,
            "previousAISKnowledgeSource": previousAISKnowledeSource.count > 1 ? previousAISKnowledeSource : "None" ,
            "previousInspectionSource": previousInspectionSource.count > 1 ? previousInspectionSource : "None",
            "generalComment": generalComments.count > 1 ? generalComments : "None",
            "launchedOutsideBC": launchedOutsideBC,
            "decontaminationPerformed": decontaminationPerformed,
            "commerciallyHauled": commerciallyHauled,
            "highRiskArea": highRiskArea,
            "highRiskAIS": highriskAIS,
            "previousInspectionDays": previousInspectionDays,
            "passportNumber": passportNumber.count > 1 ? passportNumber : "None",
            "provinceOfResidence": province.count > 1 ? province : "None",
            "journeys": []
        ]
        
        if highRiskAssessmentForm.count > 0 {
            body["highRiskAssessment"] = highRiskAssessmentForm
        }
        
        if journeysBody.count > 1 {
            body["journeys"] = journeysBody
        }
        
        return body
    }
    
    func getJourneyDetailsDictionary() -> [[String: Any]]{
        var journeys: [[String: Any]] = [[String: Any] ()]
        journeys.removeAll()
        
        for previousJourney in self.previousWaterBodies {
            let journeyDict = previousJourney.toDictionary()
            if journeyDict.count > 1 {
                journeys.append(journeyDict)
            }
            
        }
        
        for destinationJourney in self.destinationWaterBodies {
            let journeyDict = destinationJourney.toDictionary()
            if journeyDict.count > 1 {
                journeys.append(journeyDict)
            }
        }
        
        
        return journeys
    }
    
    // MARK: Journey details
    
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
                self.previousWaterBodies[index].set(value: value, for: key)
            }
        } else if inputItemKey.contains("destinationWaterBody") {
            // Destination Water Body
            let splitKey = inputItemKey.split(separator: "-")
            guard let index = Int(splitKey[2]) else {return}
            let key = String(splitKey[1])
            if self.destinationWaterBodies.count - 1 >= index {
                self.destinationWaterBodies[index].set(value: value, for: key)
            }
        }
    }
    
    func editHighRiskForm(inputItemKey: String, value: Any) {
        guard let highRiskForm = self.highRiskAssessments.first else {
            return
        }
        let splitKey = inputItemKey.split(separator: "-")
        let key = String(splitKey[1])
        highRiskForm.set(value: value, for: key)
    }
    
    func removePreviousWaterBody(at index: Int) {
        if index > self.previousWaterBodies.count - 1 {
            return
        }
        do {
            let realm = try Realm()
            try realm.write {
                self.previousWaterBodies.remove(at: index)
            }
            
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
        }
    }
    
    func removeDestinationWaterBody(at index: Int) {
        if index > self.destinationWaterBodies.count - 1 {
            return
        }
        do {
            let realm = try Realm()
            try realm.write {
                self.destinationWaterBodies.remove(at: index)
            }
            
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
        }
    }
    
    func addDestinationWaterBody() {
        do {
            let realm = try Realm()
            try realm.write {
                self.destinationWaterBodies.append(DestinationWaterbodyModel())
            }
            
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
        }
    }
    
    func addPreviousWaterBody() {
        do {
            let realm = try Realm()
            try realm.write {
                self.previousWaterBodies.append(PreviousWaterbodyModel())
            }
            
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
        }
    }
    
    // MARK: UI Helpers
    func getInputputFields(for section: WatercraftFromSection, editable: Bool? = nil) -> [InputItem] {
        switch section {
        case .PassportInfo:
            return WatercraftInspectionFormHelper.getPassportFields(for: self, editable: editable)
        case .BasicInformation:
            return WatercraftInspectionFormHelper.getBasicInfoFields(for: self, editable: editable)
        case .WatercraftDetails:
            return WatercraftInspectionFormHelper.getWatercraftDetailsFields(for: self, editable: editable)
        case .JourneyDetails:
            return WatercraftInspectionFormHelper.getPassportFields(for: self, editable: editable)
        case .InspectionDetails:
            return WatercraftInspectionFormHelper.getInspectionDetailsFields(for: self, editable: editable)
        case .GeneralComments:
            return WatercraftInspectionFormHelper.getGeneralCommentsFields(for: self, editable: editable)
        case .HighRiskAssessmentFields:
            return WatercraftInspectionFormHelper.getHighriskAssessmentFieldsFields(for: self, editable: editable)
        case .Divider:
            return []
        case .HighRiskAssessment:
            return []
        }
    }
}
