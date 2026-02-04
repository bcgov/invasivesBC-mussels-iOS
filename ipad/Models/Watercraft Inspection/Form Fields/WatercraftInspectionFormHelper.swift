//
//  WatercraftInspectionFormHelper.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-12.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
class WatercraftInspectionFormHelper {
    
    static func getPassportFields(for object: WatercraftInspectionModel? = nil, editable: Bool? = true) -> [InputItem] {
        var items: [InputItem] = []
        
        let isPassportHolder = RadioSwitchInput(
            key: "isPassportHolder",
            header: WatercraftFieldHeaderConstants.Passport.isPassportHolder,
            editable: editable ?? true,
            value: object?.isPassportHolder ?? nil,
            width: .Full
        )
        items.append(isPassportHolder)
        
        let isNewPassportIssued = RadioSwitchInput(
            key: "isNewPassportIssued",
            header: WatercraftFieldHeaderConstants.Passport.isNewPassportIssued,
            editable: editable ?? true,
            value: object?.isNewPassportIssued ?? nil,
            width: .Full)
        isNewPassportIssued.dependency.append(InputDependency(to: isPassportHolder, equalTo: true))
        items.append(isNewPassportIssued)
        
        let inspectionTime = TimeInput(
            key: "inspectionTime",
            header: WatercraftFieldHeaderConstants.Passport.inspectionTime,
            editable: editable ?? true,
            value: object?.inspectionTime ?? nil,
            width: .Third
        )
        inspectionTime.dependency.append(InputDependency(to: isPassportHolder, equalTo: true))
        items.append(inspectionTime)
        
        let passportNumber = TextInput(
            key: "passportNumber",
            header: WatercraftFieldHeaderConstants.Passport.passportNumber,
            editable: editable ?? true,
            value: object?.passportNumber ?? nil,
            validation: .PassportNumber,
            width: .Third
        )
        passportNumber.dependency.append(InputDependency(to: isPassportHolder, equalTo: true))
        items.append(passportNumber)
        
        let launchedOutsideBC = SwitchInput(
            key: "launchedOutsideBC",
            header: WatercraftFieldHeaderConstants.Passport.launchedOutsideBC,
            editable: editable ?? true,
            value: object?.launchedOutsideBC ?? nil,
            width: .Third
        )
        launchedOutsideBC.dependency.append(InputDependency(to: isPassportHolder, equalTo: true))
        items.append(launchedOutsideBC)
        
        let k9Inspection = NullSwitchInput(
            key: "k9Inspection",
            header: WatercraftFieldHeaderConstants.Passport.k9Inspection,
            editable: editable ?? true,
            value: object?.k9Inspection ?? nil,
            width: .Third,
            validationName: .k9InspectionInteracted,
            interacted: object?.k9InspectionInteracted ?? false
        )
        k9Inspection.dependency.append(InputDependency(to: isPassportHolder, equalTo: true))
        items.append(k9Inspection)
        
        let k9InspectionResults = DropdownInput(
            key: "k9InspectionResults",
            header: WatercraftFieldHeaderConstants.Passport.k9InspectionResults,
            editable: editable ?? true,
            value: object?.k9InspectionResults ?? "",
            width: .Third,
            dropdownItems: DropdownHelper.shared.getDropdown(for: .k9InspectionResults)
        )
        k9InspectionResults.dependency.append(InputDependency(to: k9Inspection, equalTo: true))
        k9InspectionResults.dependency.append(InputDependency(to: isPassportHolder, equalTo: true))
        items.append(k9InspectionResults)
        
        let marineSpeciesFound = SwitchInput(
            key: "marineSpeciesFound",
            header: WatercraftFieldHeaderConstants.Passport.marineSpeciesFound,
            editable: editable ?? true,
            value: object?.marineSpeciesFound ?? nil,
            width: .Third
        )
        marineSpeciesFound.dependency.append(InputDependency(to: isPassportHolder, equalTo: true))
        items.append(marineSpeciesFound)
        
        let aquaticPlantsFound = SwitchInput(
            key: "aquaticPlantsFound",
            header: WatercraftFieldHeaderConstants.Passport.aquaticPlantsFound,
            editable: editable ?? true,
            value: object?.aquaticPlantsFound ?? nil,
            width: .Third
        )
        aquaticPlantsFound.dependency.append(InputDependency(to: isPassportHolder, equalTo: true))
        items.append(aquaticPlantsFound)
        
        var decontaminationValue: String? = nil
        var decontaminationPerformedValue: Bool? = nil
        if let highRiskForm = object?.highRiskAssessments.first {
            decontaminationValue = highRiskForm.decontaminationReference
            decontaminationPerformedValue = highRiskForm.decontaminationPerformed
        }
        
        let decontaminationPerformed = SwitchInput(
            key: "highRisk-decontaminationPerformed",
            header: WatercraftFieldHeaderConstants.Passport.decontaminationPerformed,
            editable: editable ?? true,
            value: decontaminationPerformedValue ?? nil,
            width: .Third
        )
        decontaminationPerformed.dependency.append(InputDependency(to: isPassportHolder, equalTo: true))
        items.append(decontaminationPerformed)
        
        let decontaminationReference = TextInput (
            key: "highRisk-decontaminationReference",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.decontaminationReference,
            editable: editable ?? true,
            value: decontaminationValue ?? "",
            validation: .AlphaNumberic,
            width: .Half
        )
        decontaminationReference.dependency.append(InputDependency(to: decontaminationPerformed, equalTo: true))
        decontaminationReference.dependency.append(InputDependency(to: isPassportHolder, equalTo: true))
        items.append(decontaminationReference)
        
        return items
    }
    
    static func getBasicInfoFields(for object: WatercraftInspectionModel? = nil, editable: Bool? = true, passportField: RadioSwitchInput) -> [InputItem] {
        var sectionItems: [InputItem] = []
        let province = DropdownInput(
            key: "countryProvince",
            header: WatercraftFieldHeaderConstants.BasicInfo.province,
            editable: editable ?? true,
            value: object?.countryProvince ?? "",
            width: .Third,
            dropdownItems: DropdownHelper.shared.getDropdownForProvinces(),
            codes: DropdownHelper.shared.getProvinceCodes()
        )
        sectionItems.append(province)

        let officerInspection = SwitchInput(
            key: "officerInspection",
            header: WatercraftFieldHeaderConstants.Passport.officerInspection,
            editable: editable ?? true,
            value: object?.officerInspection ?? nil,
            width: .Third
        )
        sectionItems.append(officerInspection)
        
        let inspectionTime = TimeInput(
            key: "inspectionTime",
            header: WatercraftFieldHeaderConstants.Passport.inspectionTime,
            editable: editable ?? true,
            value: object?.inspectionTime ?? nil,
            width: .Third
        )
        inspectionTime.dependency.append(InputDependency(to: passportField, equalTo: false))
        sectionItems.append(inspectionTime)
        
        let spacer = InputSpacer(width: .Third)
        spacer.dependency.append(InputDependency(to: passportField, equalTo: true))
        sectionItems.append(spacer)
        
        let nonMotorized = IntegerStepperInput(
            key: "nonMotorized",
            header: WatercraftFieldHeaderConstants.BasicInfo.nonMotorized,
            editable: editable ?? true,
            value: object?.nonMotorized ?? 0,
            width: .Forth
        )
        sectionItems.append(nonMotorized)
        
        let simple = IntegerStepperInput(
            key: "simple",
            header: WatercraftFieldHeaderConstants.BasicInfo.simple,
            editable: editable ?? true,
            value: object?.simple ?? 0,
            width: .Forth
        )
        sectionItems.append(simple)
        
        let complex = IntegerStepperInput(
            key: "complex",
            header: WatercraftFieldHeaderConstants.BasicInfo.complex,
            editable: editable ?? true,
            value: object?.complex ?? 0,
            width: .Forth
        )
        sectionItems.append(complex)
        
        let veryComplex = IntegerStepperInput(
            key: "veryComplex",
            header: WatercraftFieldHeaderConstants.BasicInfo.veryComplex,
            editable: editable ?? true,
            value: object?.veryComplex ?? 0,
            width: .Forth
        )
        sectionItems.append(veryComplex)
        
        return sectionItems
    }
    
    static func getWatercraftDetailsFields(for object: WatercraftInspectionModel? = nil, editable: Bool? = true) -> [InputItem] {
        var sectionItems: [InputItem] = []
        let numberOfPeopleInParty = IntegerStepperInput(
            key: "numberOfPeopleInParty",
            header: WatercraftFieldHeaderConstants.WatercraftDetails.numberOfPeopleInParty,
            editable: editable ?? true,
            value: object?.numberOfPeopleInParty ?? 0,
            width: .Third
        )
        sectionItems.append(numberOfPeopleInParty)
        
        let commerciallyHauled = NullSwitchInput(
            key: "commerciallyHauled",
            header: WatercraftFieldHeaderConstants.WatercraftDetails.commerciallyHauled,
            editable: editable ?? true,
            value: object?.commerciallyHauled ?? false,
            width: .Third,
            validationName: .commerciallyHauledInteracted,
            interacted: object?.commerciallyHauledInteracted ?? false
        )
        sectionItems.append(commerciallyHauled)
        sectionItems.append(InputSpacer())
        
        let previousAISKnowlede = NullSwitchInput(
            key: "previousAISKnowlede",
            header: WatercraftFieldHeaderConstants.WatercraftDetails.previousAISKnowlede,
            editable: editable ?? true,
            value: object?.previousAISKnowlede ?? nil,
            width: .Full,
            validationName: .previousAISKnowledeInteracted,
            interacted: object?.previousAISKnowledeInteracted ?? false
        )
        sectionItems.append(previousAISKnowlede)
        
        let previousAISKnowledeSource = DropdownInput(
            key: "previousAISKnowledeSource",
            header: WatercraftFieldHeaderConstants.WatercraftDetails.previousAISKnowledeSource,
            editable: editable ?? true,
            value: object?.previousAISKnowledeSource ?? nil,
            width: .Full,
            dropdownItems: DropdownHelper.shared.getDropDownObject(for: .previousAISKnowledgeSource),
            codes: DropdownHelper.shared.getDropDownCodes(for: .previousAISKnowledgeSource)
        )
        previousAISKnowledeSource.dependency.append(InputDependency(to: previousAISKnowlede, equalTo: true))
        sectionItems.append(previousAISKnowledeSource)
        
        /// ---------------------------
        
        let previousInspection = NullSwitchInput(
            key: "previousInspection",
            header: WatercraftFieldHeaderConstants.WatercraftDetails.previousInspection,
            editable: editable ?? true,
            value: object?.previousInspection ?? nil,
            width: .Full,
            validationName: .previousInspectionInteracted,
            interacted: object?.previousInspectionInteracted ?? false
        )
        sectionItems.append(previousInspection)
        
        
        let previousInspectionSource = DropdownInput(
            key: "previousInspectionSource",
            header: WatercraftFieldHeaderConstants.WatercraftDetails.previousInspectionSource,
            editable: editable ?? true,
            value: object?.previousInspectionSource ?? nil,
            width: .Full,
            dropdownItems: DropdownHelper.shared.getDropDownObject(for: .previousInspectionSource),
            codes: DropdownHelper.shared.getDropDownCodes(for: .previousInspectionSource)
        )
        
        previousInspectionSource.dependency.append(InputDependency(to: previousInspection, equalTo: true))
        sectionItems.append(previousInspectionSource)
        
        let previousInspectionDays = DropdownInput(
            key: "previousInspectionDays",
            header: WatercraftFieldHeaderConstants.WatercraftDetails.previousInspectionDays,
            editable: editable ?? true,
            value: object?.previousInspectionDays ?? nil,
            width: .Full,
            dropdownItems: DropdownHelper.shared.getDropdown(for: .daysSincePreviousInspection)
        )
        previousInspectionDays.dependency.append(InputDependency(to: previousInspection, equalTo: true))
        sectionItems.append(previousInspectionDays)
        
        return sectionItems
    }
    
    static func getInspectionDetailsFields(for object: WatercraftInspectionModel? = nil, editable: Bool? = true, passportField: RadioSwitchInput) -> [InputItem]  {
        var sectionItems: [InputItem] = []
        let aquaticPlantsFound = NullSwitchInput(
            key: "aquaticPlantsFound",
            header: WatercraftFieldHeaderConstants.InspectionDetails.aquaticPlantsFound,
            editable: editable ?? true,
            value: object?.aquaticPlantsFound ?? false,
            width: .Full,
            validationName: .aquaticPlantsFoundInteracted,
            interacted: object?.aquaticPlantsFoundInteracted ?? false
        )
        sectionItems.append(aquaticPlantsFound)
        
        let marineMusselsFound = NullSwitchInput(
            key: "marineMusselsFound",
            header: WatercraftFieldHeaderConstants.InspectionDetails.marineMusselsFound,
            editable: editable ?? true,
            value: object?.marineMusselsFound ?? false,
            width: .Full,
            validationName: .marineMusselsFoundInteracted,
            interacted: object?.marineMusselsFoundInteracted ?? false
        )
        sectionItems.append(marineMusselsFound)
        
        let highRiskArea = NullSwitchInput(
            key: "highRiskArea",
            header: WatercraftFieldHeaderConstants.WatercraftDetails.highRiskArea,
            editable: editable ?? true,
            value: object?.highRiskArea ?? false,
            width: .Full,
            validationName: .highRiskAreaInteracted,
            interacted: object?.highRiskAreaInteracted ?? false
        )
        sectionItems.append(highRiskArea)

//        let cleanDrainDryAfter = RadioSwitchInput(
//            key: "cleanDrainDryAfterInspection",
//            header: WatercraftFieldHeaderConstants.WatercraftDetails.cleanDrainDryAfter,
//            editable: editable ?? true,
//            value: object?.cleanDrainDryAfterInspection ?? nil,
//            width: .Full
//        )
//        sectionItems.append(cleanDrainDryAfter)

        let dreissenidMusselsFoundPrevious = NullSwitchInput(
            key: "dreissenidMusselsFoundPrevious",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.dreisennidFoundPrevious,
            editable: editable ?? true,
            value: object?.dreissenidMusselsFoundPrevious ?? false,
            width: .Full,
            validationName: .dreissenidMusselsFoundPreviousInteracted,
            interacted: object?.dreissenidMusselsFoundPreviousInteracted ?? false
        )
        sectionItems.append(dreissenidMusselsFoundPrevious)
        
        let k9Inspection = NullSwitchInput(
            key: "k9Inspection",
            header: WatercraftFieldHeaderConstants.Passport.k9Inspection,
            editable: editable ?? true,
            value: object?.k9Inspection ?? nil,
            width: .Full,
            validationName: .k9InspectionInteracted,
            interacted: object?.k9InspectionInteracted ?? false
        )
        k9Inspection.dependency.append(InputDependency(to: passportField, equalTo: false))
        sectionItems.append(k9Inspection)
        
        let k9InspectionResults = DropdownInput(
            key: "k9InspectionResults",
            header: WatercraftFieldHeaderConstants.Passport.k9InspectionResults,
            editable: editable ?? true,
            value: object?.k9InspectionResults ?? "",
            width: .Full,
            dropdownItems: DropdownHelper.shared.getDropdown(for: .k9InspectionResults)
        )
        k9InspectionResults.dependency.append(InputDependency(to: k9Inspection, equalTo: true))
        sectionItems.append(k9InspectionResults)
          
        let watercraftHasDrainplugs = NullSwitchInput(
          key: "watercraftHasDrainplugs",
          header: WatercraftFieldHeaderConstants.InspectionDetails.watercraftHasDrainplugs,
          editable: editable ?? true,
          value: object?.watercraftHasDrainplugs ?? nil,
          width: .Full,
          validationName: .watercraftHasDrainplugsInteracted,
          interacted: object?.watercraftHasDrainplugsInteracted ?? false
        )
        sectionItems.append(watercraftHasDrainplugs)
        
        let drainplugRemovedAtInspection = NullSwitchInput(
          key: "drainplugRemovedAtInspection",
          header: WatercraftFieldHeaderConstants.InspectionDetails.drainplugRemovedAtInspection,
          editable: editable ?? true,
          value: object?.drainplugRemovedAtInspection ?? nil,
          width: .Full,
          validationName: .drainplugRemovedAtInspectionInteracted,
          interacted: object?.drainplugRemovedAtInspectionInteracted ?? false
        )
        drainplugRemovedAtInspection.dependency.append(InputDependency(to: watercraftHasDrainplugs, equalTo: true))
        sectionItems.append(drainplugRemovedAtInspection)
      
        return sectionItems
    }
    
    static func getHighriskAssessmentFieldsFields(for object: WatercraftInspectionModel? = nil, editable: Bool? = true) -> [InputItem] {
        var sectionItems: [InputItem] = []

        let highriskAIS = NullSwitchInput(
            key: "highriskAIS",
            header: WatercraftFieldHeaderConstants.HighriskAssessmentFields.highriskAIS,
            editable: editable ?? true,
            value: object?.highriskAIS ?? false,
            width: .Full,
            validationName: .highriskAISInteracted,
            interacted: object?.highriskAISInteracted ?? false
        )
        sectionItems.append(highriskAIS)

        let adultDreissenidFound = NullSwitchInput(
            key: "adultDreissenidFound",
            header: WatercraftFieldHeaderConstants.HighriskAssessmentFields.adultDreissenidFound,
            editable: editable ?? true,
            value: object?.adultDreissenidFound ?? false,
            width: .Full,
            validationName: .adultDreissenidFoundInteracted,
            interacted: object?.adultDreissenidFoundInteracted ?? false
        )
        sectionItems.append(adultDreissenidFound)

        return sectionItems
    }
    
    static func getGeneralCommentsFields(for object: WatercraftInspectionModel? = nil, editable: Bool? = true) -> [InputItem] {
        var sectionItems: [InputItem] = []
        
        let generalComments = TextAreaInput(
            key: "generalComments",
            header: WatercraftFieldHeaderConstants.GeneralComments.generalComments,
            editable: editable ?? true,
            value: object?.generalComments,
            width: .Full
        )
        
        sectionItems.append(generalComments)
        return sectionItems
    }
    
    public static func getPreviousWaterBodyFields(for object: WatercraftInspectionModel? = nil, index: Int, isEditable: Bool? = true) -> [InputItem] {
        var sectionItems: [InputItem] = []

        if (object?.previousWaterBodies.count ?? 0 > 0) {
            let item = object?.previousWaterBodies[index] ?? nil


            let numberOfDaysOut = DropdownInput(
                key: "previousWaterBody-numberOfDaysOut-\(index)",
                header: "Number of days out of waterbody? *",
                editable: isEditable ?? true,
                value: item?["numberOfDaysOut"] as? String ?? "N/A",
                width: .Full,
                dropdownItems: DropdownHelper.shared.getDropdown(for: .daysOutOfWater)
            )
            sectionItems.append(numberOfDaysOut)
        }
        return sectionItems
    }
    
    public static func getPreviousMajorCityFields(for object: WatercraftInspectionModel? = nil, index: Int, isEditable: Bool? = true) -> [InputItem] {
        var sectionItems: [InputItem] = []
        
        if (object?.previousMajorCities.count ?? 0 > 0) {
            if let item = object?.previousMajorCities[index] {
                let numberOfDaysOut = DropdownInput(
                    key: "previousMajorCity-numberOfDaysOut-\(index)",
                    header: "Number of days out of waterbody? *",
                    editable: isEditable ?? true,
                    value: item.numberOfDaysOut,
                    width: .Full,
                    dropdownItems: DropdownHelper.shared.getDropdown(for: .daysOutOfWater)
                )
                sectionItems.append(numberOfDaysOut)
            }
        }
        return sectionItems
    }
    
    public static func watercraftInspectionDestinationWaterBodyInputs(for object: WatercraftInspectionModel? = nil, index: Int, isEditable: Bool? = true) -> [InputItem] {
        let item = object?.destinationWaterBodies[index] ?? nil
        var sectionItems: [InputItem] = []
        
        let province = DropdownInput(
            key: "destinationWaterBody-province-\(index)",
            header: "Province / State",
            editable: isEditable ?? true,
            value: item?["province"] as? String ?? "",
            width: .Third,
            dropdownItems: DropdownHelper.shared.getDropdown(for: .provinces)
        )
        
        let destinationWaterBody = DropdownInput(
            key: "destinationWaterBody-waterbody-\(index)",
            header: "Destination WaterBody",
            editable: isEditable ?? true,
            value: item?["waterbody"] as? String ?? "",
            width: .Third,
            dropdownItems: DropdownHelper.shared.getDropdown(for: .waterBodies)
        )
        
        let nearestCity = DropdownInput(
            key: "destinationWaterBody-nearestCity-\(index)",
            header: "Nearest City",
            editable: isEditable ?? true,
            value: item?["nearestCity"] as? String ?? "",
            width: .Third,
            dropdownItems: DropdownHelper.shared.getDropdown(for: .cities)
        )
        
        sectionItems.append(province)
        sectionItems.append(destinationWaterBody)
        sectionItems.append(nearestCity)
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
