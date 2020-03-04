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
            key: "highRisk-watercraftRegistration",
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
            key: "highRisk-cleanDrainDryAfterInspection",
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
            key: "highRisk-standingWaterPresent",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.standingWaterPresent,
            editable: editable ?? true,
            value: object?.standingWaterPresent ?? false,
            width: .Full
        )
        sectionItems.append(standingWaterPresent)
        
        let standingWaterLocation = DropdownInput(
            key: "highRisk-standingWaterLocation",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.standingWaterLocation,
            editable: editable ?? true,
            value: object?.standingWaterLocation ?? "",
            width: .Half,
            dropdownItems: DropdownHelper.shared.getDropDownObject(for: .adultMusselsLocation),
            codes: DropdownHelper.shared.getDropDownCodes(for: .adultMusselsLocation)
        )
        
        standingWaterLocation.dependency = InputDependency(to: standingWaterPresent, equalTo: true)
        sectionItems.append(standingWaterLocation)
        
        let spacer1 = InputSpacer()
        spacer1.dependency = InputDependency(to: standingWaterPresent, equalTo: true)
        sectionItems.append(spacer1)
        /// ---------------------------
        
        let adultDreissenidMusselsFound = SwitchInput(
            key: "highRisk-adultDreissenidMusselsFound",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.adultDreissenidMusselsFound,
            editable: editable ?? true,
            value: object?.adultDreissenidMusselsFound ?? false,
            width: .Full
        )
        sectionItems.append(adultDreissenidMusselsFound)
        
        let adultDreissenidMusselsLocation = DropdownInput(
            key: "highRisk-adultDreissenidMusselsLocation",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.adultDreissenidMusselsLocation,
            editable: editable ?? true,
            value: object?.adultDreissenidMusselsLocation ?? "",
            width: .Half,
            dropdownItems: DropdownHelper.shared.getDropDownObject(for: .adultMusselsLocation),
            codes: DropdownHelper.shared.getDropDownCodes(for: .adultMusselsLocation)
        )
        
        adultDreissenidMusselsLocation.dependency = InputDependency(to: adultDreissenidMusselsFound, equalTo: true)
        sectionItems.append(adultDreissenidMusselsLocation)
        let spacer2 = InputSpacer()
        spacer2.dependency = InputDependency(to: adultDreissenidMusselsFound, equalTo: true)
        sectionItems.append(spacer2)
        /// ---------------------------
        
        let decontaminationPerformed = SwitchInput(
            key: "highRisk-adultDreissenidMusselsFound",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.decontaminationPerformed,
            editable: editable ?? true,
            value: object?.decontaminationPerformed ?? false,
            width: .Full
        )
        sectionItems.append(decontaminationPerformed)
        
        let decontaminationReference = IntegerInput(
            key: "highRisk-decontaminationReference",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.decontaminationReference,
            editable: editable ?? true,
            value: object?.decontaminationReference ?? 0,
            width: .Half
        )
        decontaminationReference.dependency = InputDependency(to: decontaminationPerformed, equalTo: true)
        sectionItems.append(decontaminationReference)
        let spacer3 = InputSpacer()
        spacer3.dependency = InputDependency(to: decontaminationPerformed, equalTo: true)
        sectionItems.append(spacer3)
        /// ---------------------------
        
        let decontaminationOrderIssued = SwitchInput(
            key: "highRisk-decontaminationOrderIssued",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.decontaminationOrderIssued,
            editable: editable ?? true,
            value: object?.decontaminationOrderIssued ?? false,
            width: .Full
        )
        sectionItems.append(decontaminationOrderIssued)
        
        let decontaminationOrderNumber = IntegerInput(
            key: "highRisk-decontaminationOrderNumber",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.decontaminationOrderNumber,
            editable: editable ?? true,
            value: object?.decontaminationOrderNumber ?? 0,
            width: .Half
        )
        decontaminationOrderNumber.dependency = InputDependency(to: decontaminationOrderIssued, equalTo: true)
        sectionItems.append(decontaminationOrderNumber)
        let spacer4 = InputSpacer()
        spacer4.dependency = InputDependency(to: decontaminationOrderIssued, equalTo: true)
        sectionItems.append(spacer4)
        /// ---------------------------
        
        let sealIssued = SwitchInput(
            key: "highRisk-sealIssued",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.sealIssued,
            editable: editable ?? true,
            value: object?.sealIssued ?? false,
            width: .Full
        )
        sectionItems.append(sealIssued)
        
        let sealNumber = IntegerInput(
            key: "highRisk-sealNumber",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.sealNumber,
            editable: editable ?? true,
            value: object?.sealNumber ?? 0,
            width: .Full
        )
        sealNumber.dependency = InputDependency(to: sealIssued, equalTo: true)
        sectionItems.append(sealNumber)
        let spacer5 = InputSpacer()
        spacer5.dependency = InputDependency(to: sealIssued, equalTo: true)
        sectionItems.append(spacer5)
        /// ---------------------------
        
        let otherInspectionFindings = DropdownInput(
            key: "highRisk-otherInspectionFindings",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.otherInspectionFindings,
            editable: editable ?? true,
            value: object?.otherInspectionFindings ?? "",
            width: .Half,
            dropdownItems: DropdownHelper.shared.getDropdown(for: .otherObservations)
        )
        sectionItems.append(otherInspectionFindings)
        
        let quarantinePeriodIssued = SwitchInput(
            key: "highRisk-quarantinePeriodIssued",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.quarantinePeriodIssued,
            editable: editable ?? true,
            value: object?.quarantinePeriodIssued ?? false,
            width: .Half
        )
        sectionItems.append(quarantinePeriodIssued)
        
        return sectionItems
    }
}
