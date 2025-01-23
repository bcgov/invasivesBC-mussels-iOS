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

class WatercraftInspectionModel: Object, BaseRealmObject {
    @objc dynamic var formDidValidate: Bool = false
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
    @objc dynamic var k9InspectionResults: String = ""
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
    @objc dynamic var previousInspectionDays: String = ""
    
    // Inspection Details
    @objc dynamic var marineMusselsFound: Bool = false
    @objc dynamic var cleanDrainDryAfterInspection: Bool = false
    @objc dynamic var dreissenidMusselsFoundPrevious: Bool = false
    @objc dynamic var watercraftHasDrainplugs: Bool = false
    @objc dynamic var drainplugRemovedAtInspection: Bool = false
    
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
    
    var previousMajorCities: List<MajorCityModel> = List<MajorCityModel>()
    var destinationMajorCities: List<MajorCityModel> = List<MajorCityModel>()

    
    // High Risk Assessments
    var highRiskAssessments: List<HighRiskAssessmentModel> = List<HighRiskAssessmentModel>()
    
    @objc dynamic var status: String = "Draft"
    
    @objc dynamic var riskLevel: String = "low"
    
    private var inputputFields: [WatercraftFromSection: [InputItem]] = [WatercraftFromSection: [InputItem]]()
    
    // Passport issue flag
    @objc dynamic var isNewPassportIssued: Bool = false
    
    // Validators
    var validatorNames = ["highriskAIS",
                          "adultDreissenidFound",
                          "k9Inspection",
                          "previousInspection",
                          "commerciallyHauled",
                          "previousAISKnowlede",
                          "aquaticPlantsFound",
                          "marineMusselsFound",
                          "highRiskArea",
                          "dreissenidMusselsFoundPrevious",
                          "watercraftHasDrainplugs",
                          "drainplugRemovedAtInspection"]
    @objc dynamic var highriskAISInteracted: Bool = false
    @objc dynamic var adultDreissenidFoundInteracted: Bool = false
    @objc dynamic var k9InspectionInteracted: Bool = false
    @objc dynamic var previousInspectionInteracted: Bool = false
    @objc dynamic var commerciallyHauledInteracted: Bool = false
    @objc dynamic var previousAISKnowledeInteracted: Bool = false
    @objc dynamic var aquaticPlantsFoundInteracted: Bool = false
    @objc dynamic var marineMusselsFoundInteracted: Bool = false
    @objc dynamic var highRiskAreaInteracted: Bool = false
    @objc dynamic var dreissenidMusselsFoundPreviousInteracted: Bool = false
    @objc dynamic var drainplugRemovedAtInspectionInteracted: Bool = false
    @objc dynamic var watercraftHasDrainplugsInteracted: Bool = false
    
     private static let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "UTC")!
        return formatter
    }()

    
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
        if key == "highriskAIS" || key == "cleanDrainDryAfterInspection" || key == "adultDreissenidFound" {
            setRiskLevel()
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
        if (formDidValidate) {
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
        } else {
            // If form isn't validated, force status to Errors
            set(status: .Errors)
        }
    }
    
    func set(status statusEnum: SyncableItemStatus) {
        var newStatus = "\(statusEnum)"
        switch statusEnum {
        case .Draft:
            newStatus = formDidValidate ? "Draft" : "Not Validated"
        case .PendingSync:
           newStatus = formDidValidate ? "Pending Sync" : "Not Validated"
        case .Completed:
            newStatus = "Completed"
        case .Errors:
            newStatus = "Not Validated"
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
        if self.adultDreissenidFound == true {
            assessment.adultDreissenidMusselsFound = true
        }

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
        case "not validated":
            return .Errors
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
        dateFormatter.timeZone = TimeZone(identifier: "UTC")!
        let formattedDateFull = dateFormatter.string(from: self.timeStamp)

        guard let formattedInspectionTime = formattedDateTime(time: inspectionTime, date: timeStamp) else {
            return [String: Any]()
        }
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
            "isNewPassportIssued": isNewPassportIssued,
            "inspectionTime": formattedInspectionTime,
            "k9Inspection": k9Inspection,
            "k9InspectionResults": k9InspectionResults,
            "watercraftHasDrainplugs": watercraftHasDrainplugs,
            "drainplugRemovedAtInspection": drainplugRemovedAtInspection,
            "marineSpeciesFound": marineSpeciesFound,
            "aquaticPlantsFound": aquaticPlantsFound,
            "previousAISKnowledge": previousAISKnowlede,
            "previousInspection": previousInspection,
            "marineMusselFound": marineMusselsFound,
            "cleanDrainDryAfterInspection": cleanDrainDryAfterInspection,
            "adultDreissenidaeFound": adultDreissenidFound,
            "dreissenidMusselsFoundPrevious": dreissenidMusselsFoundPrevious,
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
            "previousMajorCity": previousMajorCities.count > 0 ? (previousMajorCities[0].majorCity + ", " + previousMajorCities[0].province + ", " + previousMajorCities[0].country) : "None",
            "destinationMajorCity": destinationMajorCities.count > 0 ? (destinationMajorCities[0].majorCity + ", " + destinationMajorCities[0].province + ", " + destinationMajorCities[0].country) : "None",
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
    
    func deleteMajorCity(isPrevious: Bool) {
        do {
            let realm = try Realm()
            try realm.write {
                if isPrevious {
                    self.previousMajorCities.removeAll()
                } else {
                    self.destinationMajorCities.removeAll()
                }
            }
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
        }
    }
    
    func setMajorCity(isPrevious: Bool, majorCity: MajorCitiesTableModel) {
        let object = MajorCityModel()
        object.set(from: majorCity)
        do {
            let realm = try Realm()
            try realm.write {
                if isPrevious {
                    self.previousMajorCities.removeAll()
                    self.previousMajorCities.append(object)

                } else {
                    self.destinationMajorCities.removeAll()
                    self.destinationMajorCities.append(object)
                }
            }
        } catch let error as NSError {
            ErrorLog("** REALM ERROR: \(error)")
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
    
    func getPreviousWaterBodyInputFields(for section: WatercraftFromSection, editable: Bool? = nil, index: Int) -> [InputItem] {
        if let existing = inputputFields[section] { return existing}
        var inputFields: [WatercraftFromSection: [InputItem]] = [WatercraftFromSection: [InputItem]]()
        inputFields[section] = WatercraftInspectionFormHelper.getPreviousWaterBodyFields(for: self, index: index, isEditable: editable)
        return inputFields[section] ?? []
    }
    
    // MARK: UI Helpers
    func getInputputFields(for section: WatercraftFromSection, editable: Bool? = nil) -> [InputItem] {
        if let existing = inputputFields[section] { return existing}
        
        var inputputFields: [WatercraftFromSection: [InputItem]] = [WatercraftFromSection: [InputItem]]()
        let passportFields = WatercraftInspectionFormHelper.getPassportFields(for: self, editable: editable)
        var passportHolderField: InputItem? = nil
        for field in passportFields where field.key.lowercased() == "isPassportHolder".lowercased() {
            passportHolderField = field
        }
        guard let _passportHolderField = passportHolderField as? RadioSwitchInput else {return []}
        inputputFields[.PassportInfo] = passportFields
        inputputFields[.BasicInformation] = WatercraftInspectionFormHelper.getBasicInfoFields(for: self, editable: editable, passportField: _passportHolderField)
        inputputFields[.WatercraftDetails] = WatercraftInspectionFormHelper.getWatercraftDetailsFields(for: self, editable: editable)
        inputputFields[.InspectionDetails] = WatercraftInspectionFormHelper.getInspectionDetailsFields(for: self, editable: editable, passportField: _passportHolderField)
        inputputFields[.GeneralComments] = WatercraftInspectionFormHelper.getGeneralCommentsFields(for: self, editable: editable)
        inputputFields[.HighRiskAssessmentFields] = WatercraftInspectionFormHelper.getHighriskAssessmentFieldsFields(for: self, editable: editable)
        inputputFields[.Divider] = []
        inputputFields[.HighRiskAssessment] = []
        return inputputFields[section] ?? []
    }

    // Add the linkToShift property to access parent shift
    let linkToShift = LinkingObjects(fromType: ShiftModel.self, property: "inspections")

    func formattedDateTime(time: String, date: Date) -> String? {
        let timeParts = time.components(separatedBy: ":")
        
        // Validate time format
        guard timeParts.count == 2,
              let hour = Int(timeParts[0]),
              let minute = Int(timeParts[1]),
              hour >= 0 && hour < 24,
              minute >= 0 && minute < 60 else {
            return nil
        }
        
        // Get station timezone from parent shift
        guard let parentShift = linkToShift.first else { return nil }
        let stationTimezone = ShiftModel.getTimezoneForStation(parentShift.station)
        
        // Create a calendar in the station's timezone
        var calendar = Calendar.current
        calendar.timeZone = stationTimezone
        
        // Check if this is an overnight shift
        var targetDate = date
        if let shiftStartTime = Int(parentShift.startTime.components(separatedBy: ":")[0]),
           let inspectionHour = Int(time.components(separatedBy: ":")[0]) {
            if shiftStartTime > inspectionHour {
                // If shift start hour is greater than inspection hour, this is next day
                targetDate = calendar.date(byAdding: .day, value: 1, to: date) ?? date
            }
        }
        
        var components = calendar.dateComponents([.year, .month, .day], from: targetDate)
        components.hour = hour
        components.minute = minute
        components.second = 1
        
        guard let localDate = calendar.date(from: components) else {
            return nil
        }
        
        return WatercraftInspectionModel.dateTimeFormatter.string(from: localDate)
    }
}
