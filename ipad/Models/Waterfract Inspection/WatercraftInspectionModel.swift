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
    // Province of residence
    @objc dynamic var countryProvince: String = ""
    // Key for Remote DB
    @objc dynamic var provinceOfResidence = ""
    @objc dynamic var countryOfResidence = ""
    
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
    
    // Dry Storage
    @objc dynamic var previousDryStorage: Bool = false
    @objc dynamic var destinationDryStorage: Bool = false
    
    // Unknown
    @objc dynamic var unknownPreviousWaterBody: Bool = false
    @objc dynamic var unknownDestinationWaterBody: Bool = false
    
    // Commercial manufacturer
    @objc dynamic var commercialManufacturerAsPreviousWaterBody: Bool = false
    @objc dynamic var commercialManufacturerAsDestinationWaterBody: Bool = false
    
    // High Risk Assesment fields
    @objc dynamic var highriskAIS: Bool = false
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
    
    private var inputputFields: [WatercraftFromSection: [InputItem]] = [WatercraftFromSection: [InputItem]]()
    
    // Passport issue flag
    @objc dynamic var isNewPassportIssued: Bool = false
    
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
        if key == "highriskAIS" || key == "adultDreissenidFound" {
            setRiskLevel()
        }
    }
    
    func setRiskLevel() {
        if highriskAIS == true || adultDreissenidFound == true {
            set(value: "High", for: "riskLevel")
        } else {
            set(value: "Low", for: "riskLevel")
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
        set(status: should ? .PendingSync : .Draft )
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
        set(status: should ? .PendingSync : .Draft )
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
    
    func removeHighRiskAssessment() {
        do {
            let realm = try Realm()
            try realm.write {
                self.highRiskAssessments.removeAll()
            }
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
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
        dateFormatter.dateFormat = "YYYY-MM-dd'T'HH:mm:ss.SSSZ"
        let formattedDateFull = dateFormatter.string(from: self.timeStamp)
        print(formattedDateFull)
        
        // Create dictionary for high-risk assessment
        var highRiskAssessmentForm: [String: Any] = [String: Any] ()
        if let highRiskAssessment = self.highRiskAssessments.first {
            highRiskAssessmentForm = highRiskAssessment.toDictionary()
        }
        
        let journeysBody = getJourneyDetailsDictionary()
        
        let previousAISKnowledeSourceId: Int? = Storage.shared.codeId(type: .previousAISKnowledgeSource, name: previousAISKnowledeSource)
        let previousInspectionSourceId: Int? = Storage.shared.codeId(type: .previousInspectionSource, name: previousInspectionSource)

        var _decontaminationPerformed = false
        if let highRisk = highRiskAssessments.first {
            _decontaminationPerformed = highRisk.decontaminationPerformed
        }
        
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
            "generalComment": generalComments.count > 1 ? generalComments : "None",
            "launchedOutsideBC": launchedOutsideBC,
            "commerciallyHauled": commerciallyHauled,
            "decontaminationPerformed": _decontaminationPerformed,
            "highRiskArea": highRiskArea,
            "highRiskAIS": highriskAIS,
            "previousInspectionDays": previousInspectionDays,
            "passportNumber": passportNumber.count > 1 ? passportNumber : "None",
            "previousDryStorage": previousDryStorage,
            "destinationDryStorage": destinationDryStorage,
            "unknownPreviousWaterBody": unknownPreviousWaterBody,
            "unknownDestinationWaterBody": unknownDestinationWaterBody,
            "commercialManufacturerAsPreviousWaterBody": commercialManufacturerAsPreviousWaterBody,
            "commercialManufacturerAsDestinationWaterBody": commercialManufacturerAsDestinationWaterBody,
            "provinceOfResidence": provinceOfResidence != "" ? provinceOfResidence : "BC",
            "countryOfResidence": countryOfResidence != "" ? countryOfResidence : "CAN",
            "numberOfPeopleInParty": numberOfPeopleInParty,
            "journeys": []
        ]
        
        if let _previousAISKnowledeSourceId = previousAISKnowledeSourceId, previousAISKnowlede {
            body[ "previousAISKnowledgeSource"] = _previousAISKnowledeSourceId
        }
        
        if let _previousInspectionSourceId = previousInspectionSourceId, previousInspection {
            body["previousInspectionSource"] = _previousInspectionSourceId
        }
        
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
        let splitKey = inputItemKey.split(separator: "-")
        let key = String(splitKey[1])
        if let highRiskForm = self.highRiskAssessments.first {
           highRiskForm.set(value: value, for: key)
        } else if let newHighRiskForm = self.addHighRiskAssessment() {
            newHighRiskForm.set(value: value, for: key)
        }
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
    
    
    func addDestinationWaterBody(model: WaterBodyTableModel) {
        let object = DestinationWaterbodyModel()
        object.set(from: model)
        do {
            let realm = try Realm()
            try realm.write {
                self.destinationWaterBodies.append(object)
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
    
    func addPreviousWaterBody(model: WaterBodyTableModel) {
        let object = PreviousWaterbodyModel()
        object.set(from: model)
        do {
            let realm = try Realm()
            try realm.write {
                self.previousWaterBodies.append(object)
            }
            
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
        }
    }
    
    
    func setJournyStatusFlags(dryStorage: Bool, unknown: Bool, commercialManufacturer: Bool, isPrevious: Bool) {
        do {
            // Removing existing waterbodies
            // 1. Convert into array iterator
            let waterBodies: [Any] = isPrevious ? Array(self.previousWaterBodies) : Array(self.destinationWaterBodies)
            // 2. Removing each item
            for item in waterBodies {
                if let body: JourneyModel = item as? JourneyModel {
                    guard
                        let realm = try? Realm(),
                        let object = realm.objects(JourneyModel.self).filter("localId = %@", body.localId).first else {
                            continue
                    }
                    RealmRequests.deleteObject(object)
                }
            }
            
            let relam = try Realm()
            try relam.write {
                if isPrevious {
                    self.previousDryStorage = dryStorage
                    self.unknownPreviousWaterBody = unknown
                    self.commercialManufacturerAsPreviousWaterBody = commercialManufacturer
                    self.previousWaterBodies =  List<PreviousWaterbodyModel>()
                } else {
                    self.destinationDryStorage = dryStorage
                    self.unknownDestinationWaterBody = unknown
                    self.commercialManufacturerAsDestinationWaterBody = commercialManufacturer
                    self.destinationWaterBodies = List<DestinationWaterbodyModel>()
                }
            }
            
        } catch let error as NSError {
            ErrorLog("** RELAM ERROR: \(error)")
        }
    }
    
    
    
    // MARK: UI Helpers
    func getInputputFields(for section: WatercraftFromSection, editable: Bool? = nil) -> [InputItem] {
        if let existing = inputputFields[section] { return existing}
        
        var inputputFields: [WatercraftFromSection: [InputItem]] = [WatercraftFromSection: [InputItem]]()
        var passportFields = WatercraftInspectionFormHelper.getPassportFields(for: self, editable: editable)
        var passportHolderField: InputItem? = nil
        for field in passportFields where field.key.lowercased() == "isPassportHolder".lowercased() {
            passportHolderField = field
        }
        guard let _passportHolderField = passportHolderField as? RadioSwitchInput else {return []}
        inputputFields[.PassportInfo] = passportFields
        inputputFields[.BasicInformation] = WatercraftInspectionFormHelper.getBasicInfoFields(for: self, editable: editable, passportField: _passportHolderField)
        inputputFields[.WatercraftDetails] = WatercraftInspectionFormHelper.getWatercraftDetailsFields(for: self, editable: editable)
        inputputFields[.JourneyDetails] = WatercraftInspectionFormHelper.getPassportFields(for: self, editable: editable)
        inputputFields[.InspectionDetails] = WatercraftInspectionFormHelper.getInspectionDetailsFields(for: self, editable: editable)
        inputputFields[.GeneralComments] = WatercraftInspectionFormHelper.getGeneralCommentsFields(for: self, editable: editable)
        inputputFields[.HighRiskAssessmentFields] = WatercraftInspectionFormHelper.getHighriskAssessmentFieldsFields(for: self, editable: editable)
        inputputFields[.Divider] = []
        inputputFields[.HighRiskAssessment] = []
        return inputputFields[section] ?? []
    }
}
