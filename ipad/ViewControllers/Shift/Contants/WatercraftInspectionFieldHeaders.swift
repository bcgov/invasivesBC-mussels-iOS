//
//  WatercraftInspectionFieldHeaders.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-12.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation

struct ShiftFormHeaders {
    struct ShiftStart {
        static let startTime = "Shift Start Time"
        static let k9OnShift = "k9 On Shift"
        static let station = "Station"
        static let weatherConditions = "Weather Conditions"
        static let sunny = "Sunny"
        static let cloudy = "Cloudy"
        static let raining = "Raining"
        static let snowing = "Snowing"
        static let foggy = "Foggy"
        static let windy = "Windy"
        static let comments = "Additional Comments"
    }
    
    struct ShiftEnd {
        static let endTime = "Shift End Time"
        static let boatsInspected = "Boats Inspected During Shift?"
        static let motorizedBlowBys = "Motorized blow-bys"
        static let nonMotorizedBlowBys = "Non Motorized blow-Bys"
        static let comments = "Additional Comments"
    }
}


struct WatercraftFieldHeaderConstants {
    struct Passport {
        static let isPassportHolder = "Is this a Passport Holder?"
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
    }
    struct InspectionDetails {
        static let aquaticPlantsFound = "Aquatic plants found"
        static let marineMusslesFound = "Marine mussels or barnacles found"
        static let failedToStop = "Watercraft pulled over for failing to stop at the inspection station"
        static let ticketIssued = "Violation ticket issued"
    }
    struct HighriskAssessmentFields {
        static let highriskAIS = "Watercraft/equipment high risk for dreissenid or other AIS *"
        static let adultDreissenidFound = "Adult dreissenid mussels found"
    }
    struct GeneralComments {
        static let generalComments = "General Comments"
    }
}
