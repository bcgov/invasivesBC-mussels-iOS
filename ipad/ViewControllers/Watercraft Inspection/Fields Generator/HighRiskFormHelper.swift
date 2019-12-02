//
//  HighRiskFormHelper.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-12.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
class HighRiskFormHelper {
    
    static func getBasicInfoFields(for object: HighRiskAssessmentModel? = nil, editable: Bool? = true) -> [InputItem] {
        var sectionItems: [InputItem] = []
        let watercraftRegistration = IntegerInput(
            key: "watercraftRegistration",
            header: HighRiskFormFieldHeaders.BasicInformation.watercraftRegistration,
            editable: editable ?? true,
            value: object?.watercraftRegistration ?? 0,
            width: .Full
        )
        sectionItems.append(watercraftRegistration)
        return sectionItems
    }
    
    static func getInspectionFields(for object: HighRiskAssessmentModel? = nil, editable: Bool? = true) -> [InputItem] {
        var sectionItems: [InputItem] = []
        let cleanDrainDryAfterInspection = RadioSwitchInput(
            key: "cleanDrainDryAfterInspection",
            header: HighRiskFormFieldHeaders.Inspection.cleanDrainDryAfterInspection,
            editable: editable ?? true,
            value: object?.cleanDrainDryAfterInspection ?? nil,
            width: .Full
        )
        sectionItems.append(cleanDrainDryAfterInspection)
        return sectionItems
    }
    
    static func getInspectionOutcomesFields(for object: HighRiskAssessmentModel? = nil, editable: Bool? = true) -> [InputItem] {
        var sectionItems: [InputItem] = []
        let standingWaterPresent = SwitchInput(
            key: "standingWaterPresent",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.standingWaterPresent,
            editable: editable ?? true,
            value: object?.standingWaterPresent ?? false,
            width: .Full
        )
        sectionItems.append(standingWaterPresent)
        
        let standingWaterLocation = TextInput(
            key: "standingWaterLocation",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.standingWaterLocation,
            editable: editable ?? true,
            value: object?.standingWaterLocation ?? "",
            width: .Full
        )
        standingWaterLocation.dependency = InputDependency(to: standingWaterPresent, equalTo: true)
        sectionItems.append(standingWaterLocation)
        
       
        let adultDreissenidMusselsFound = SwitchInput(
            key: "adultDreissenidMusselsFound",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.adultDreissenidMusselsFound,
            editable: editable ?? true,
            value: object?.adultDreissenidMusselsFound ?? false,
            width: .Full
        )
        sectionItems.append(adultDreissenidMusselsFound)
        
        let adultDreissenidMusselsLocation = TextInput(
            key: "adultDreissenidMusselsLocation",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.adultDreissenidMusselsLocation,
            editable: editable ?? true,
            value: object?.adultDreissenidMusselsLocation ?? "",
            width: .Full
        )
        adultDreissenidMusselsLocation.dependency = InputDependency(to: adultDreissenidMusselsFound, equalTo: true)
        sectionItems.append(adultDreissenidMusselsLocation)
        
        let decontaminationPerformed = SwitchInput(
            key: "adultDreissenidMusselsFound",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.decontaminationPerformed,
            editable: editable ?? true,
            value: object?.decontaminationPerformed ?? false,
            width: .Full
        )
        sectionItems.append(decontaminationPerformed)
        
        let decontaminationReference = IntegerInput(
            key: "decontaminationReference",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.decontaminationReference,
            editable: editable ?? true,
            value: object?.decontaminationReference ?? 0,
            width: .Full
        )
        decontaminationReference.dependency = InputDependency(to: decontaminationPerformed, equalTo: true)
        sectionItems.append(decontaminationReference)
        
        let decontaminationOrderIssued = SwitchInput(
            key: "decontaminationOrderIssued",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.decontaminationOrderIssued,
            editable: editable ?? true,
            value: object?.decontaminationOrderIssued ?? false,
            width: .Full
        )
        sectionItems.append(decontaminationOrderIssued)
        
        let decontaminationOrderNumber = IntegerInput(
            key: "decontaminationOrderNumber",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.decontaminationOrderNumber,
            editable: editable ?? true,
            value: object?.decontaminationOrderNumber ?? 0,
            width: .Full
        )
        decontaminationOrderNumber.dependency = InputDependency(to: decontaminationOrderIssued, equalTo: true)
        sectionItems.append(decontaminationOrderNumber)
        
        let sealIssued = SwitchInput(
            key: "sealIssued",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.sealIssued,
            editable: editable ?? true,
            value: object?.sealIssued ?? false,
            width: .Full
        )
        sectionItems.append(sealIssued)
        
        let sealNumber = IntegerInput(
            key: "sealNumber",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.sealNumber,
            editable: editable ?? true,
            value: object?.sealNumber ?? 0,
            width: .Full
        )
        sealNumber.dependency = InputDependency(to: sealIssued, equalTo: true)
        sectionItems.append(sealNumber)
        
        let otherInspectionFindings = DropdownInput(
            key: "otherInspectionFindings",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.otherInspectionFindings,
            editable: editable ?? true,
            value: object?.otherInspectionFindings ?? "",
            width: .Half,
            dropdownItems: DropdownHelper.shared.getDropdown(for: .otherObservations)
        )
        sectionItems.append(otherInspectionFindings)
        
        let quarantinePeriodIssued = SwitchInput(
            key: "quarantinePeriodIssued",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.quarantinePeriodIssued,
            editable: editable ?? true,
            value: object?.quarantinePeriodIssued ?? false,
            width: .Half
        )
        sectionItems.append(quarantinePeriodIssued)
        
        return sectionItems
    }
    
    static func getGeneralCommentsFields(for object: HighRiskAssessmentModel? = nil, editable: Bool? = true) -> [InputItem] {
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
}
