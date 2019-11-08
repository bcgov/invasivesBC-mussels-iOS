//
//  FormHelper.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-05.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation

class FormHelper {
    
    public static func getDummyOptions() -> [DropdownModel]{
        var options: [DropdownModel] = []
        options.append(DropdownModel(display: "Something here"))
        options.append(DropdownModel(display: "Something else here"))
        options.append(DropdownModel(display: "Something more here"))
        options.append(DropdownModel(display: "Another thing"))
        return options
    }
    
    public static func watercraftInspectionBasciInfoInputs(isEditable: Bool? = true) -> [InputItem] {
        var sectionItems: [InputItem] = []
        let dateOfInspection = DateInput(key: "dateOfInspection", header: "Date of inspection", editable: isEditable ?? true, width: .Forth)
        let provinceOfBoatResidence = DropdownInput(key: "provinceOfBoatResidence", header: "State / Province of boat residence", editable: isEditable ?? true, width: .Forth, dropdownItems: getDummyOptions())
        let numberOfWatercrafts = DropdownInput(key: "numberOfWatercrafts", header: "Number of Watercrafts", editable: isEditable ?? true, width: .Forth, dropdownItems: getDummyOptions())
        let multipleTypesOfCraft = SwitchInput(key: "multipleTypesOfCraft", header: "Multiple types of watercraft?", editable: isEditable ?? true, width: .Forth)
        sectionItems.append(dateOfInspection)
        sectionItems.append(provinceOfBoatResidence)
        sectionItems.append(numberOfWatercrafts)
        sectionItems.append(multipleTypesOfCraft)
        return sectionItems
    }
    
    public static func watercraftInspectionWatercraftDetailsInputs(isEditable: Bool? = true) -> [InputItem] {
        var sectionItems: [InputItem] = []
        let numberOfPeople = TextInput(key: "numberOfPeople", header: "Number of people in the party?", editable: isEditable ?? true, width: .Third)
        
        let commerciallyHauled =  SwitchInput(key: "commerciallyHauled", header: "Was the watercraft/equipment commercially hauled?", editable: isEditable ?? true, width: .Third)
        let highRiskArea =  SwitchInput(key: "highRiskArea", header: "Is the watercraft coming froma high risk area for whirling disease?", editable: isEditable ?? true, width: .Third)
        let previousInspection =  SwitchInput(key: "previousInspection", header: "Any previous inspection and/ or agency notification?", editable: isEditable ?? true, width: .Third)
        let previousAISknowledge =  SwitchInput(key: "previousAISknowledge", header: "Previous knowledge of AIS or Clean, Drai, Dry?", editable: isEditable ?? true, width: .Third)
        
        sectionItems.append(numberOfPeople)
        sectionItems.append(commerciallyHauled)
        sectionItems.append(highRiskArea)
        sectionItems.append(previousInspection)
        sectionItems.append(previousAISknowledge)
        return sectionItems
    }
    
    public static func watercraftInspectionInspectionDetailsInputs(isEditable: Bool? = true) -> [InputItem] {
        var sectionItems: [InputItem] = []
        
        let aquaticPlantsFound =  SwitchInput(key: "aquaticPlantsFound", header: "Any Aquatic plants found?", editable: isEditable ?? true, width: .Third)
        let marineMusslesFound =  SwitchInput(key: "marineMusslesFound", header: "Any marine mussels or barnacles found?", editable: isEditable ?? true, width: .Third)
        let failedToStop =  SwitchInput(key: "failedToStop", header: "Was the watercraft pulled over for failing to stop at the inspection station?", editable: isEditable ?? true, width: .Third)
        let adultDreissenidFound =  SwitchInput(key: "adultDreissenidFound", header: "Were adult dreissenid mussels found?", editable: isEditable ?? true, width: .Third)
        let highRiskForDreissenid =  SwitchInput(key: "highRiskForDreissenid", header: "Is the wartercraft/equipment high risk for dreissenid or other AIS? *", editable: isEditable ?? true, width: .Third)
        let passportIssued =  SwitchInput(key: "passportIssued", header: "Was a Passport issued?", editable: isEditable ?? true, width: .Third)
        passportIssued.dependency = InputDependency(to: aquaticPlantsFound, equalTo: true)
        
        sectionItems.append(aquaticPlantsFound)
        sectionItems.append(marineMusslesFound)
        sectionItems.append(failedToStop)
        sectionItems.append(adultDreissenidFound)
        sectionItems.append(highRiskForDreissenid)
        sectionItems.append(passportIssued)
        return sectionItems
    }
    
    public static func watercraftInspectionCommentSectionInputs(isEditable: Bool? = true) -> [InputItem] {
        var sectionItems: [InputItem] = []
        let generalComments = TextAreaInput(key: "generalComments", header: "General Comments", editable: isEditable ?? true)
        sectionItems.append(generalComments)
        return sectionItems
    }
    
    public static func watercraftInspectionPreviousWaterBodyInputs(index: Int, isEditable: Bool? = true) -> [InputItem] {
        var sectionItems: [InputItem] = []
        let previousWaterBody = DropdownInput(key: "previousWaterBody-\(index)", header: "Previous WaterBody", editable: isEditable ?? true, width: .Forth, dropdownItems: getDummyOptions())
        let nearestCity = DropdownInput(key: "previousWaterBody-nearestCity-\(index)", header: "Nearest City", editable: isEditable ?? true, width: .Forth, dropdownItems: getDummyOptions())
        let province = DropdownInput(key: "previousWaterBody-province-\(index)", header: "Province / State", editable: isEditable ?? true, width: .Forth, dropdownItems: getDummyOptions())
        let numberOfDaysOut = TextInput(key: "previousWaterBody-numberOfDaysOut-\(index)", header: "Number of days out of waterbody?", editable: isEditable ?? true, width: .Forth)
        
        sectionItems.append(previousWaterBody)
        sectionItems.append(nearestCity)
        sectionItems.append(province)
        sectionItems.append(numberOfDaysOut)
        return sectionItems
    }
    
    public static func watercraftInspectionDestinationWaterBodyInputs(index: Int, isEditable: Bool? = true) -> [InputItem] {
        var sectionItems: [InputItem] = []
        let destinationWaterBody = DropdownInput(key: "destinationWaterBody-\(index)", header: "Destination WaterBody", editable: isEditable ?? true, width: .Third, dropdownItems: getDummyOptions())
        let nearestCity = DropdownInput(key: "destinationWaterBody-NearestCity-\(index)", header: "Nearest City", editable: isEditable ?? true, width: .Third, dropdownItems: getDummyOptions())
        let province = DropdownInput(key: "destinationWaterBody-province-\(index)", header: "Province / State", editable: isEditable ?? true, width: .Third, dropdownItems: getDummyOptions())
        
        sectionItems.append(destinationWaterBody)
        sectionItems.append(nearestCity)
        sectionItems.append(province)
        return sectionItems
    }
}
