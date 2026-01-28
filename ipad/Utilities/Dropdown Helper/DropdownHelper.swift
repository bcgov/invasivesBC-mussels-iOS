//
//  DropdownHelper.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-26.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation

extension Array where Element : Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues += [item]
            }
        }
        return uniqueValues
    }
}

class DropdownHelper {
    
    static let shared = DropdownHelper()
    private init() {}
    
    public func getDropdown(for type: CodeTableType) -> [DropdownModel] {
        let items = Storage.shared.codeTable(type: type)
        
        // We'll be using custom sorting for the station list, as per service owner request
        if type == .stations {
            return dropdownWithCustomStationSort(from: items)
        }
        
        return dropdown(from: items, sort: false)
    }
    
    // Custom dropdown sorting function, used to put each station in a category, then sort each category alphabetically
    private func dropdownWithCustomStationSort(from items: [String]) -> [DropdownModel] {
        let uniqueItems = Array(Set(items))
        
        // Categorize stations (permanent, various roving stations, and the special stations (other, emergency and project))
        let permanentStations = uniqueItems.filter { isPermanentStation($0) }.sorted()
        let lowerMainlandRoving = uniqueItems.filter { $0.contains("Lower Mainland Roving") }.sorted()
        let pacificBorderRoving = uniqueItems.filter { $0 == "Pacific Border" }
        let pentictonRoving = uniqueItems.filter { $0.contains("Penticton Roving") }.sorted()
        let cranbrookRoving = uniqueItems.filter { $0.contains("Cranbrook Roving") }.sorted()
        let sumasRoving = uniqueItems.filter {$0 == "Sumas/Huntington" }
        let specialStations = uniqueItems.filter { isSpecialStation($0) }.sorted()
        
        // Combine all of our stations in the desired order
        let sortedItems = permanentStations + lowerMainlandRoving + pacificBorderRoving + pentictonRoving + cranbrookRoving + sumasRoving + specialStations
        
        // Convert to DropdownModel objects
        return sortedItems.map { DropdownModel(display: $0) }
    }
    
    // Check if a station is a permanent, this will have to be adjusted when the station list changes in the future along with the other checks
    private func isPermanentStation(_ station: String) -> Bool {
        let permanentStations = [
            "Cutts (Hwy 93)", "Dawson Creek", "Golden", "Mt. Robson", 
            "Olsen (Hwy 3)", "Osoyoos", "Radium", "Yahk"
        ]
        return permanentStations.contains(station)
    }
    
    private func isSpecialStation(_ station: String) -> Bool {
        let specialStations = ["Emergency Response", "Other", "Project"]
        return specialStations.contains(station)
    }
    
    public func getDropDownObject(for type: CodeTableType) -> [DropdownModel] {
        return dropdown(from: Storage.shared.codeObjects(type: type), sort: false)
    }
    
    public func getDropDownCodes(for type: CodeTableType ) -> [CodeObject] {
        return Storage.shared.codes(type: type)
    }
    
    public func getDropdownForProvinces() -> [DropdownModel] {
        return dropdown(from: Storage.shared.provinces(), sort: true)
    }
    
    public func getProvinceCodes() -> [CountryProvince] {
        return Storage.shared.provincesCodes()
    }
    
    public func dropdown(from items: [String], sort: Bool) -> [DropdownModel] {
        var options: [DropdownModel] = []
        var set = Array(Set(items)).sorted()
        if (sort) {
            let CAN = set.filter({$0.contains("CAN")}).sorted()
            let USA = set.filter({$0.contains("USA")}).sorted()
            let MEX = set.filter({$0.contains("MEX")}).sorted()
            set = CAN + USA + MEX
        }
        for item in set {
            options.append(DropdownModel(display: item))
        }
        return options
    }
    
    public func dropdownContains(key: String, dropdownItems: [DropdownModel]) -> Bool {
        for item in dropdownItems where item.key == key {
            return true
        }
        return false
    }
}
