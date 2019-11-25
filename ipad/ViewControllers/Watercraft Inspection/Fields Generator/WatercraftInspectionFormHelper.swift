//
//  WatercraftInspectionFormHelper.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-12.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
class WatercraftInspectionFormHelper {
    private static func getDummyOptions() -> [DropdownModel]{
        var options: [DropdownModel] = []
        options.append(DropdownModel(display: "Something here"))
        options.append(DropdownModel(display: "Something else here"))
        options.append(DropdownModel(display: "Something more here"))
        options.append(DropdownModel(display: "Another thing"))
        return options
    }
    
    static func getPassportFields(for object: WatercradftInspectionModel? = nil, editable: Bool? = true) -> [InputItem] {
        var items: [InputItem] = []
        
        let isPassportHolder = RadioSwitchInput(
            key: "isPassportHolder",
            header: WatercraftFieldHeaderConstants.Passport.isPassportHolder,
            editable: editable ?? true,
            value: object?.isPassportHolder ?? nil,
            width: .Full
        )
        items.append(isPassportHolder)
        
        let inspectionTime = DoubleInput(
            key: "inspectionTime",
            header: WatercraftFieldHeaderConstants.Passport.inspectionTime,
            editable: editable ?? true,
            value: object?.inspectionTime ?? nil,
            width: .Third
        )
        inspectionTime.dependency = InputDependency(to: isPassportHolder, equalTo: true)
        items.append(inspectionTime)
        
        let passportNumber = TextInput(
            key: "PassportNumber",
            header: WatercraftFieldHeaderConstants.Passport.passportNumber,
            editable: editable ?? true,
            value: object?.passportNumber ?? nil,
            width: .Third
        )
        passportNumber.dependency = InputDependency(to: isPassportHolder, equalTo: true)
        items.append(passportNumber)
        
        let launchedOutsideBC = SwitchInput(
            key: "launchedOutsideBC",
            header: WatercraftFieldHeaderConstants.Passport.launchedOutsideBC,
            editable: editable ?? true,
            value: object?.launchedOutsideBC ?? nil,
            width: .Third
        )
        launchedOutsideBC.dependency = InputDependency(to: isPassportHolder, equalTo: true)
        items.append(launchedOutsideBC)
        
        let k9Inspection = SwitchInput(
            key: "k9Inspection",
            header: WatercraftFieldHeaderConstants.Passport.k9Inspection,
            editable: editable ?? true,
            value: object?.k9Inspection ?? nil,
            width: .Third
        )
        k9Inspection.dependency = InputDependency(to: isPassportHolder, equalTo: true)
        items.append(k9Inspection)
        
        let marineSpeciesFound = SwitchInput(
            key: "marineSpeciesFound",
            header: WatercraftFieldHeaderConstants.Passport.marineSpeciesFound,
            editable: editable ?? true,
            value: object?.marineSpeciesFound ?? nil,
            width: .Third
        )
        marineSpeciesFound.dependency = InputDependency(to: isPassportHolder, equalTo: true)
        items.append(marineSpeciesFound)
        
        let aquaticPlantsFound = SwitchInput(
            key: "aquaticPlantsFound",
            header: WatercraftFieldHeaderConstants.Passport.aquaticPlantsFound,
            editable: editable ?? true,
            value: object?.aquaticPlantsFound ?? nil,
            width: .Third
        )
        aquaticPlantsFound.dependency = InputDependency(to: isPassportHolder, equalTo: true)
        items.append(aquaticPlantsFound)
        
        let decontaminationPerformed = SwitchInput(
            key: "decontaminationPerformed",
            header: WatercraftFieldHeaderConstants.Passport.decontaminationPerformed,
            editable: editable ?? true,
            value: object?.decontaminationPerformed ?? nil,
            width: .Third
        )
        decontaminationPerformed.dependency = InputDependency(to: isPassportHolder, equalTo: true)
        items.append(decontaminationPerformed)
        
        return items
    }
    
    static func getBasicInfoFields(for object: WatercradftInspectionModel? = nil, editable: Bool? = true) -> [InputItem] {
        var sectionItems: [InputItem] = []
        let province = DropdownInput(
            key: "province",
            header: WatercraftFieldHeaderConstants.BasicInfo.province,
            editable: editable ?? true,
            value: object?.province ?? "",
            width: .Full,
            dropdownItems: getDummyOptions()
        )
        sectionItems.append(province)
        
        let nonMotorized = IntegerInput(
            key: "nonMotorized",
            header: WatercraftFieldHeaderConstants.BasicInfo.nonMotorized,
            editable: editable ?? true,
            value: object?.nonMotorized ?? 0,
            width: .Third
        )
        sectionItems.append(nonMotorized)
        
        let simple = IntegerInput(
            key: "simple",
            header: WatercraftFieldHeaderConstants.BasicInfo.simple,
            editable: editable ?? true,
            value: object?.simple ?? 0,
            width: .Third
        )
        sectionItems.append(simple)
        
        let complex = IntegerInput(
            key: "complex",
            header: WatercraftFieldHeaderConstants.BasicInfo.complex,
            editable: editable ?? true,
            value: object?.complex ?? 0,
            width: .Third
        )
        sectionItems.append(complex)
        
        let veryComplex = IntegerInput(
            key: "veryComplex",
            header: WatercraftFieldHeaderConstants.BasicInfo.veryComplex,
            editable: editable ?? true,
            value: object?.veryComplex ?? 0,
            width: .Third
        )
        sectionItems.append(veryComplex)
        
        return sectionItems
    }
    
    static func getWatercraftDetailsFields(for object: WatercradftInspectionModel? = nil, editable: Bool? = true) -> [InputItem] {
        var sectionItems: [InputItem] = []
        let numberOfPeopleInParty = IntegerInput(
            key: "numberOfPeopleInParty",
            header: WatercraftFieldHeaderConstants.WatercraftDetails.numberOfPeopleInParty,
            editable: editable ?? true,
            value: object?.numberOfPeopleInParty ?? 0,
            width: .Third
        )
        sectionItems.append(numberOfPeopleInParty)
        
        let commerciallyHauled = IntegerInput(
            key: "commerciallyHauled",
            header: WatercraftFieldHeaderConstants.WatercraftDetails.commerciallyHauled,
            editable: editable ?? true,
            value: object?.commerciallyHauled ?? 0,
            width: .Third
        )
        sectionItems.append(commerciallyHauled)
        
        let highRiskArea = SwitchInput(
            key: "highRiskArea",
            header: WatercraftFieldHeaderConstants.WatercraftDetails.highRiskArea,
            editable: editable ?? true,
            value: object?.highRiskArea ?? nil,
            width: .Third
        )
        sectionItems.append(highRiskArea)
        
        let previousAISKnowlede = SwitchInput(
            key: "previousAISKnowlede",
            header: WatercraftFieldHeaderConstants.WatercraftDetails.previousAISKnowlede,
            editable: editable ?? true,
            value: object?.previousAISKnowlede ?? nil,
            width: .Full
        )
        sectionItems.append(previousAISKnowlede)
        
        let previousAISKnowledeSource = TextInput(
            key: "previousAISKnowledeSource",
            header: WatercraftFieldHeaderConstants.WatercraftDetails.previousAISKnowledeSource,
            editable: editable ?? true,
            value: object?.previousAISKnowledeSource ?? nil,
            width: .Full
        )
        previousAISKnowledeSource.dependency = InputDependency(to: previousAISKnowlede, equalTo: true)
        sectionItems.append(previousAISKnowledeSource)
        
        let previousInspection = SwitchInput(
            key: "previousInspection",
            header: WatercraftFieldHeaderConstants.WatercraftDetails.previousInspection,
            editable: editable ?? true,
            value: object?.previousInspection ?? nil,
            width: .Full
        )
        sectionItems.append(previousInspection)
        
        let previousInspectionSource = TextInput(
            key: "previousInspectionSource",
            header: WatercraftFieldHeaderConstants.WatercraftDetails.previousInspectionSource,
            editable: editable ?? true,
            value: object?.previousInspectionSource ?? nil,
            width: .Third
        )
        previousInspectionSource.dependency = InputDependency(to: previousInspection, equalTo: true)
        sectionItems.append(previousInspectionSource)
        
        let previousInspectionDays = IntegerInput(
            key: "previousInspectionDays",
            header: WatercraftFieldHeaderConstants.WatercraftDetails.previousInspectionDays,
            editable: editable ?? true,
            value: object?.previousInspectionDays ?? 0,
            width: .Third
        )
        previousInspectionDays.dependency = InputDependency(to: previousInspection, equalTo: true)
        sectionItems.append(previousInspectionDays)
        
        return sectionItems
    }
    
    static func getInspectionDetailsFields(for object: WatercradftInspectionModel? = nil, editable: Bool? = true) -> [InputItem] {
        var sectionItems: [InputItem] = []
        let aquaticPlantsFound = SwitchInput(
            key: "aquaticPlantsFound",
            header: WatercraftFieldHeaderConstants.InspectionDetails.aquaticPlantsFound,
            editable: editable ?? true,
            value: object?.aquaticPlantsFound ?? nil,
            width: .Forth
        )
        sectionItems.append(aquaticPlantsFound)
        
        let marineMusslesFound = SwitchInput(
            key: "marineMusslesFound",
            header: WatercraftFieldHeaderConstants.InspectionDetails.marineMusslesFound,
            editable: editable ?? true,
            value: object?.marineMusslesFound ?? nil,
            width: .Forth
        )
        sectionItems.append(marineMusslesFound)
        
        let failedToStop = SwitchInput(
            key: "failedToStop",
            header: WatercraftFieldHeaderConstants.InspectionDetails.failedToStop,
            editable: editable ?? true,
            value: object?.failedToStop ?? nil,
            width: .Forth
        )
        sectionItems.append(failedToStop)
        
        let ticketIssued = SwitchInput(
            key: "ticketIssued",
            header: WatercraftFieldHeaderConstants.InspectionDetails.ticketIssued,
            editable: editable ?? true,
            value: object?.ticketIssued ?? nil,
            width: .Forth
        )
        sectionItems.append(ticketIssued)
        return sectionItems
    }
    
    static func getHighriskAssessmentFieldsFields(for object: WatercradftInspectionModel? = nil, editable: Bool? = true) -> [InputItem] {
        var sectionItems: [InputItem] = []
        let highriskAIS = SwitchInput(
            key: "highriskAIS",
            header: WatercraftFieldHeaderConstants.HighriskAssessmentFields.highriskAIS,
            editable: editable ?? true,
            value: object?.highriskAIS ?? nil,
            width: .Half
        )
        sectionItems.append(highriskAIS)
        
        let adultDreissenidFound = SwitchInput(
            key: "adultDreissenidFound",
            header: WatercraftFieldHeaderConstants.HighriskAssessmentFields.adultDreissenidFound,
            editable: editable ?? true,
            value: object?.adultDreissenidFound ?? nil,
            width: .Half
        )
        sectionItems.append(adultDreissenidFound)
        return sectionItems
    }
    
    static func getGeneralCommentsFields(for object: WatercradftInspectionModel? = nil, editable: Bool? = true) -> [InputItem] {
        var sectionItems: [InputItem] = []
        let generalComments = TextAreaInput(
            key: "generalComments",
            header: "General Comments",
            editable: editable ?? true,
            value: object?.generalComments ?? "",
            width: .Full
        )
        sectionItems.append(generalComments)
        return sectionItems
    }
    
    static func getTableColumns() -> [TableViewColumnConfig] {
        // Create Column Config
        var columns: [TableViewColumnConfig] = []
        columns.append(TableViewColumnConfig(key: "", header: "#", type: .Counter, showHeader: false))
        columns.append(TableViewColumnConfig(key: "remoteId", header: "ID", type: .Normal))
        columns.append(TableViewColumnConfig(key: "riskLevel", header: "Risk Level", type: .Normal))
        columns.append(TableViewColumnConfig(key: "timeAdded", header: "Time Added", type: .Normal))
        columns.append(TableViewColumnConfig(key: "status", header: "Status", type: .WithIcon))
        columns.append(TableViewColumnConfig(key: "", header: "Actions", type: .Button, buttonName: "View", showHeader: false))
        return columns
    }
}
