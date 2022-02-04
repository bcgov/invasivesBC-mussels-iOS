//
//  StringConstants.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-28.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation

enum AlertMessage {
    case Logout
    case IsOffline
    case NeedsAccess
    case NothingToSync
    case SyncIsDisabled
    case LoginExpired
}

struct StringConstants {
    // MARK: App title
    static let appTitle: String = "Mussel Inspect App"
    struct Alerts {
        // MARK: Alerts
        struct Logout {
            static let title: String = "Would you like to logout?"
            static let message: String = ""
        }
        
        struct IsOffline {
            static let title: String = "Can't Synchronize"
            static let message: String = "Device is offline"
        }
        
        struct NeedsAccess {
            static let title: String = "Access Deined"
            static let message: String = "You need the required access level to submit.\nAccess request has been created and is awaiting approval"
        }
        
        struct NothingToSync {
            static let title: String = "Nothing to sync"
            static let message: String = "There is nothing to sync"
        }
        
        struct SyncIsDisabled {
            static let title: String = "Sync is disabled"
            static let message: String = "Please re-start application"
        }
        
        struct LoginExpired {
            static let title: String = "Authentication Required"
            static let message: String = "You need to authenticate to perform the initial sync.\n Would you like to authenticate now and synchronize?\n\nIf you select no, You will not be able to create records.\n"
        }
    }
    
    struct EmptyTable {
        static let title: String = ""
        static let shifts: String = ""
        static let inspections: String = ""
    }
}

// MARK: Shift
struct ShiftFormHeaders {
    struct ShiftStart {
        static let startTime = "Shift Start Time"
        static let k9OnShift = "k9 On Shift"
        static let station = "Station"
        static let comments = "Shift Start Comments"
    }
    
    struct ShiftEnd {
        static let endTime = "Shift End Time"
        static let boatsInspected = "Boats Inspected During Shift?"
        static let motorizedBlowBys = "Motorized blow-bys"
        static let nonMotorizedBlowBys = "Non Motorized blow-Bys"
        static let comments = "Shift End Comments"
    }
}

// MARK: Watercraft Inspection
struct WatercraftFieldHeaderConstants {
    struct Passport {
        static let isPassportHolder = "Is this a Passport Holder?"
        static let isNewPassportIssued = "Was a new passport issued?"
        static let inspectionTime = "Time of Inspection"
        static let passportNumber = "Passport Number"
        static let launchedOutsideBC = "Launched outside BC/AB in the last 30 days?"
        static let k9Inspection = "k9 Inspection Performed?"
        static let decontaminationPerformed = "Decontamination Performed?"
        static let marineSpeciesFound = "Marine Species Found"
        static let aquaticPlantsFound = "Aquatic Plants Found"
    }
    struct BasicInfo {
        static let province = "Province/State of Boat Residence"
        static let nonMotorized = "Non-Motorized"
        static let simple = "Simple"
        static let complex = "Complex"
        static let veryComplex = "Very Complex"
    }
    struct WatercraftDetails {
        static let numberOfPeopleInParty = "Number of people in the party"
        static let commerciallyHauled = "Watercraft/equipment commercially hauled"
        static let highRiskArea = "Watercraft coming from a high risk area for whirling disease"
        static let previousAISKnowlede = "Previous Knowledge of AIS or Clean, Drain, Dry"
        static let previousAISKnowledeSource = "Source"
        static let previousInspection = "Previous inspection and/or agency notification"
        static let previousInspectionSource = "Source"
        static let previousInspectionDays = "No. Of Days"
        static let cleanDrainDryAfter = "Is the watercraft Clean, Drain, Dry after full inspection without taking any further action?"
    }
    struct InspectionDetails {
        static let aquaticPlantsFound = "Aquatic plants found"
        static let marineMusslesFound = "Marine mussels or barnacles found"
        static let failedToStop = "Watercraft pulled over for failing to stop at the inspection station"
        static let ticketIssued = "Violation ticket issued"
    }
    struct HighriskAssessmentFields {
        static let highriskAIS = "Is the watercraft high risk for dreissenid mussels or other AIS?"
        static let adultDreissenidFound = "Adult dreissenid mussels found"
    }
    struct GeneralComments {
        static let generalComments = "Inspection Comments"
    }
}

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
        static let adultDreissenidMusselsLocation = "Adult Dreissenid mussels location"
        static let dreisennidFoundPrevious = "Dreissenid mussels found on previous inspection"
        static let decontaminationPerformed = "Decontamination performed?"
        static let decontaminationReference = "Record of Decontamination number"
        static let decontaminationOrderIssued = "Decontamination order issued?"
        static let decontaminationOrderNumber = "Decontamination order number"
        static let decontaminationOrderReason = "Reason for issuing decontamination order"
        static let decontaminationAppendixB = "Appendix B filled out?"
        static let sealIssued = "Seal issued?"
        static let sealNumber = "Seal #"
    }
    
    struct GeneralComments {
        static let generalComments = "General Comments"
    }
}
