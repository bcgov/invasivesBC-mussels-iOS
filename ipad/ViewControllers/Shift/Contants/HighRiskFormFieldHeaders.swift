//
//  HighRiskFormFieldHeaders.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-12.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation

struct HighRiskFormFieldHeaders {
    
    struct BasicInformation {
        static let watercraftRegistration = "Watercraft registration # (if applicable)"
    }
    
    struct Inspection {
         static let cleanDrainDryAfterInspection = "Clean, Drain, Dry after inspection"
    }
    
    struct InspectionOutcomes {
        static let otherInspectionFindings = "Other inspection findings"
        static let quarantinePeriodIssued = "Quarantine period issued?"
        static let standingWaterPresent = "Standing water present?"
        static let standingWaterLocation = "Standing Water Location"
        static let adultDreissenidMusselsFound = "Adult Dreissendid mussels found?"
        static let adultDreissenidMusselsLocation = "Adult Dreissendid mussels location"
        static let decontaminationPerformed = "Decontamination performed?"
        static let decontaminationReference = "Record of Decontamination reference number#"
        static let decontaminationOrderIssued = "Decontamination order issued?"
        static let decontaminationOrderNumber = "Decontamination order number"
        static let sealIssued = "Seal issued?"
        static let sealNumber = "Seal #"
    }
    struct GeneralComments {
        static let generalComments = "General Comments"
    }
}
