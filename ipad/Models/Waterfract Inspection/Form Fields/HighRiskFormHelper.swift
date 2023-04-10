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
        let watercraftRegistration = TextInput(
            key: "highRisk-watercraftRegistration",
            header: HighRiskFormFieldHeaders.BasicInformation.watercraftRegistration,
            editable: editable ?? true,
            value: object?.watercraftRegistration ?? "",
            validation: .AlphaNumberic,
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
        
        standingWaterLocation.dependency.append(InputDependency(to: standingWaterPresent, equalTo: true))
        sectionItems.append(standingWaterLocation)
        
        let standingWaterLocation1 = DropdownInput(
            key: "highRisk-standingWaterLocation1",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.standingWaterLocationAlt,
            editable: editable ?? true,
            value: object?.standingWaterLocation1 ?? "",
            width: .Half,
            dropdownItems: DropdownHelper.shared.getDropDownObject(for: .adultMusselsLocation),
            codes: DropdownHelper.shared.getDropDownCodes(for: .adultMusselsLocation)
        )
        
        standingWaterLocation1.dependency.append(InputDependency(to: standingWaterPresent, equalTo: true))
        sectionItems.append(standingWaterLocation1)
        
        let standingWaterLocation2 = DropdownInput(
            key: "highRisk-standingWaterLocation2",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.standingWaterLocationAlt,
            editable: editable ?? true,
            value: object?.standingWaterLocation2 ?? "",
            width: .Half,
            dropdownItems: DropdownHelper.shared.getDropDownObject(for: .adultMusselsLocation),
            codes: DropdownHelper.shared.getDropDownCodes(for: .adultMusselsLocation)
        )
        
        standingWaterLocation2.dependency.append(InputDependency(to: standingWaterPresent, equalTo: true))
        sectionItems.append(standingWaterLocation2)
        
        let standingWaterLocation3 = DropdownInput(
            key: "highRisk-standingWaterLocation3",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.standingWaterLocationAlt,
            editable: editable ?? true,
            value: object?.standingWaterLocation3 ?? "",
            width: .Half,
            dropdownItems: DropdownHelper.shared.getDropDownObject(for: .adultMusselsLocation),
            codes: DropdownHelper.shared.getDropDownCodes(for: .adultMusselsLocation)
        )
        
        standingWaterLocation3.dependency.append(InputDependency(to: standingWaterPresent, equalTo: true))
        sectionItems.append(standingWaterLocation3)
        
        let spacer1 = InputSpacer()
        spacer1.dependency.append(InputDependency(to: standingWaterPresent, equalTo: true))
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
        
        adultDreissenidMusselsLocation.dependency.append(InputDependency(to: adultDreissenidMusselsFound, equalTo: true))
        sectionItems.append(adultDreissenidMusselsLocation)
        
        let adultDreissenidMusselsLocation1 = DropdownInput(
            key: "highRisk-adultDreissenidMusselsLocation1",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.adultDreissenidMusselsLocationAlt,
            editable: editable ?? true,
            value: object?.adultDreissenidMusselsLocation1 ?? "",
            width: .Half,
            dropdownItems: DropdownHelper.shared.getDropDownObject(for: .adultMusselsLocation),
            codes: DropdownHelper.shared.getDropDownCodes(for: .adultMusselsLocation)
        )
        
        adultDreissenidMusselsLocation1.dependency.append(InputDependency(to: adultDreissenidMusselsFound, equalTo: true))
        sectionItems.append(adultDreissenidMusselsLocation1)
        
        let adultDreissenidMusselsLocation2 = DropdownInput(
            key: "highRisk-adultDreissenidMusselsLocation2",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.adultDreissenidMusselsLocationAlt,
            editable: editable ?? true,
            value: object?.adultDreissenidMusselsLocation2 ?? "",
            width: .Half,
            dropdownItems: DropdownHelper.shared.getDropDownObject(for: .adultMusselsLocation),
            codes: DropdownHelper.shared.getDropDownCodes(for: .adultMusselsLocation)
        )
        
        adultDreissenidMusselsLocation2.dependency.append(InputDependency(to: adultDreissenidMusselsFound, equalTo: true))
        sectionItems.append(adultDreissenidMusselsLocation2)
        
        let adultDreissenidMusselsLocation3 = DropdownInput(
            key: "highRisk-adultDreissenidMusselsLocation3",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.adultDreissenidMusselsLocationAlt,
            editable: editable ?? true,
            value: object?.adultDreissenidMusselsLocation3 ?? "",
            width: .Half,
            dropdownItems: DropdownHelper.shared.getDropDownObject(for: .adultMusselsLocation),
            codes: DropdownHelper.shared.getDropDownCodes(for: .adultMusselsLocation)
        )
        
        adultDreissenidMusselsLocation3.dependency.append(InputDependency(to: adultDreissenidMusselsFound, equalTo: true))
        sectionItems.append(adultDreissenidMusselsLocation3)
        /// ---------------------------
        
        let otherInspectionFindings = DropdownInput(
            key: "highRisk-otherInspectionFindings",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.otherInspectionFindings,
            editable: editable ?? true,
            value: object?.otherInspectionFindings ?? "",
            width: .Full,
            dropdownItems: DropdownHelper.shared.getDropdown(for: .otherObservations)
        )
        sectionItems.append(otherInspectionFindings)
        
        let decontaminationPerformed = NullSwitchInput(
            key: "highRisk-decontaminationPerformed",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.decontaminationPerformed,
            editable: editable ?? true,
            value: object?.decontaminationPerformed ?? false,
            width: .Full,
            validationName: .decontaminationPerformedInteracted,
            interacted: object?.decontaminationPerformedInteracted ?? false
        )
        sectionItems.append(decontaminationPerformed)
        
        let decontaminationReference = TextInput (
            key: "highRisk-decontaminationReference",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.decontaminationReference,
            editable: editable ?? true,
            value: object?.decontaminationReference ?? "",
            validation: .AlphaNumberic,
            width: .Half
        )
        decontaminationReference.dependency.append(InputDependency(to: decontaminationPerformed, equalTo: true))
        sectionItems.append(decontaminationReference)
        let spacer3 = InputSpacer()
        spacer3.dependency.append(InputDependency(to: decontaminationPerformed, equalTo: true))
        sectionItems.append(spacer3)
        /// ---------------------------
        
        let decontaminationOrderIssued = NullSwitchInput(
            key: "highRisk-decontaminationOrderIssued",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.decontaminationOrderIssued,
            editable: editable ?? true,
            value: object?.decontaminationOrderIssued ?? false,
            width: .Full,
            validationName: .decontaminationOrderIssuedInteracted,
            interacted: object?.decontaminationOrderIssuedInteracted ?? false
        )
        sectionItems.append(decontaminationOrderIssued)
        
        let decontaminationOrderNumber = IntegerInput(
            key: "highRisk-decontaminationOrderNumber",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.decontaminationOrderNumber,
            editable: editable ?? true,
            value: object?.decontaminationOrderNumber ?? 0,
            width: .Half
        )
        
        let decontaminationOrderReason = DropdownInput(
            key: "highRisk-decontaminationOrderReason",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.decontaminationOrderReason,
            editable: editable ?? true,
            value: object?.decontaminationOrderReason ?? "",
            width: .Half,
            dropdownItems: DropdownHelper.shared.getDropdown(for: .decontaminationOrderReasons)
        )
        decontaminationOrderNumber.dependency.append(InputDependency(to: decontaminationOrderIssued, equalTo: true))
        sectionItems.append(decontaminationOrderNumber)
        
        decontaminationOrderReason.dependency.append(InputDependency(to: decontaminationOrderIssued, equalTo: true))
        sectionItems.append(decontaminationOrderReason)
        
        let decontaminationAppendixB = NullSwitchInput(
            key: "highRisk-decontaminationAppendixB",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.decontaminationAppendixB,
            editable: editable ?? true,
            value: object?.decontaminationAppendixB ?? false,
            width: .Full,
            validationName: .decontaminationAppendixBInteracted,
            interacted: object?.decontaminationAppendixBInteracted ?? false
        )
        sectionItems.append(decontaminationAppendixB)
        
        let sealIssued = NullSwitchInput(
            key: "highRisk-sealIssued",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.sealIssued,
            editable: editable ?? true,
            value: object?.sealIssued ?? false,
            width: .Full,
            validationName: .sealIssuedInteracted,
            interacted: object?.sealIssuedInteracted ?? false
        )
        sectionItems.append(sealIssued)
        
        let sealNumber = IntegerInput(
            key: "highRisk-sealNumber",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.sealNumber,
            editable: editable ?? true,
            value: object?.sealNumber ?? 0,
            width: .Full
        )
        sealNumber.dependency.append(InputDependency(to: sealIssued, equalTo: true))
        sectionItems.append(sealNumber)
//        let spacer5 = InputSpacer()
//        spacer5.dependency = InputDependency(to: sealIssued, equalTo: true)
//        sectionItems.append(spacer5)
        /// ---------------------------
        
//        let dreissenidMusselsFoundPrevious = SwitchInput(
//            key: "highRisk-dreissenidMusselsFoundPrevious",
//            header: HighRiskFormFieldHeaders.InspectionOutcomes.dreisennidFoundPrevious,
//            editable: editable ?? true,
//            value: object?.dreissenidMusselsFoundPrevious ?? false,
//            width: .Full
//        )
//        sectionItems.append(dreissenidMusselsFoundPrevious)
        
        let quarantinePeriodIssued = NullSwitchInput(
            key: "highRisk-quarantinePeriodIssued",
            header: HighRiskFormFieldHeaders.InspectionOutcomes.quarantinePeriodIssued,
            editable: editable ?? true,
            value: object?.quarantinePeriodIssued ?? false,
            width: .Full,
            validationName: .quarantinePeriodIssuedInteracted,
            interacted: object?.quarantinePeriodIssuedInteracted ?? false
        )
        sectionItems.append(quarantinePeriodIssued)
        
        return sectionItems
    }
}
