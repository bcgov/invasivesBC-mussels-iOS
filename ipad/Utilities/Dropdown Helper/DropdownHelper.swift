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
        return dropdown(from: items, sort: false)
    }
    
    public func getDropDownObject(for type: CodeTableType) -> [DropdownModel] {
        return dropdown(from: Storage.shared.codeObjects(type: type), sort: false)
    }
    
    public func getDropDownCodes(for type: CodeTableType ) -> [CodeObject] {
        return Storage.shared.codes(type: type)
    }
    
    public func getDropdownForPrvinces() -> [DropdownModel] {
        return dropdown(from: Storage.shared.provinces(), sort: true)
    }
    
    public func getProvinceCodes() -> [CountryProvince] {
        return Storage.shared.provincesCodes()
    }
    
    public func dropdown(from items: [String], sort: Bool) -> [DropdownModel] {
        let sort = true;
        var options: [DropdownModel] = []
        var set = Array(Set(items))
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
