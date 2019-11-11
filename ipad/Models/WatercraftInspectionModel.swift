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
    
    
    // Form Objects (Not stored)
    private var passportFields : [InputItem]?
    
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
    
    func getPassportFields(editable: Bool? = nil) -> [InputItem] {
        if self.passportFields == nil {
            self.passportFields = WatercraftInspectionFormHelper.getPassportFields(for: self, editable: editable)
            return self.passportFields ?? []
        } else {
            return self.passportFields ?? []
        }
    }
}

struct FieldHeaderConstants {
    struct Passport {
        static let isPassportHolder = "Is this a Passport Holder?"
        static let inspectionTime = "Time of Inspection"
        static let passportNumber = "Passport Number"
        static let launchedOutsideBC = "Launched outside BC?AB in the last 30 days?"
        static let k9Inspection = "k9 Inspection Performed?"
        static let decontaminationPerformed = "Decontamination Performed?"
        static let marineSpeciesFound = "Marine Species Found"
        static let aquaticPlantsFound = "Aquatic Plants Found"
    }
    
}

class WatercraftInspectionFormHelper {
    static func getPassportFields(for object: WatercradftInspectionModel? = nil, editable: Bool? = true) -> [InputItem] {
        var items: [InputItem] = []
        
        let isPassportHolder = RadioSwitchInput(
            key: "isPassportHolder",
            header: FieldHeaderConstants.Passport.isPassportHolder,
            editable: editable ?? true,
            value: object?.isPassportHolder ?? nil,
            width: .Full
        )
        items.append(isPassportHolder)
        
        let inspectionTime = DoubleInput(
            key: "inspectionTime",
            header: FieldHeaderConstants.Passport.inspectionTime,
            editable: editable ?? true,
            value: object?.inspectionTime ?? nil,
            width: .Third
        )
        inspectionTime.dependency = InputDependency(to: isPassportHolder, equalTo: true)
        items.append(inspectionTime)
        
        let passportNumber = TextInput(
            key: "PassportNumber",
            header: FieldHeaderConstants.Passport.passportNumber,
            editable: editable ?? true,
            value: object?.passportNumber ?? nil,
            width: .Third
        )
        passportNumber.dependency = InputDependency(to: isPassportHolder, equalTo: true)
        items.append(passportNumber)
        
        let launchedOutsideBC = SwitchInput(
            key: "launchedOutsideBC",
            header: FieldHeaderConstants.Passport.launchedOutsideBC,
            editable: editable ?? true,
            value: object?.launchedOutsideBC ?? nil,
            width: .Third
        )
        launchedOutsideBC.dependency = InputDependency(to: isPassportHolder, equalTo: true)
        items.append(launchedOutsideBC)
        
        let k9Inspection = SwitchInput(
            key: "k9Inspection",
            header: FieldHeaderConstants.Passport.k9Inspection,
            editable: editable ?? true,
            value: object?.k9Inspection ?? nil,
            width: .Third
        )
        k9Inspection.dependency = InputDependency(to: isPassportHolder, equalTo: true)
        items.append(k9Inspection)
        
        let marineSpeciesFound = SwitchInput(
            key: "marineSpeciesFound",
            header: FieldHeaderConstants.Passport.marineSpeciesFound,
            editable: editable ?? true,
            value: object?.marineSpeciesFound ?? nil,
            width: .Third
        )
        marineSpeciesFound.dependency = InputDependency(to: isPassportHolder, equalTo: true)
        items.append(marineSpeciesFound)
        
        let aquaticPlantsFound = SwitchInput(
            key: "aquaticPlantsFound",
            header: FieldHeaderConstants.Passport.aquaticPlantsFound,
            editable: editable ?? true,
            value: object?.aquaticPlantsFound ?? nil,
            width: .Third
        )
        aquaticPlantsFound.dependency = InputDependency(to: isPassportHolder, equalTo: true)
        items.append(aquaticPlantsFound)
        
        let decontaminationPerformed = SwitchInput(
            key: "decontaminationPerformed",
            header: FieldHeaderConstants.Passport.decontaminationPerformed,
            editable: editable ?? true,
            value: object?.decontaminationPerformed ?? nil,
            width: .Third
        )
        decontaminationPerformed.dependency = InputDependency(to: isPassportHolder, equalTo: true)
        items.append(decontaminationPerformed)
        
        return items
    }
}
