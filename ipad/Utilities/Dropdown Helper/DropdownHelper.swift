//
//  DropdownHelper.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-26.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation

class DropdownHelper {
    
    static let shared = DropdownHelper()
    private init() {}
    
    public func getDropdown(for type: CodeTableType) -> [DropdownModel] {
        let items = Storage.shared.codeTable(type: type)
        var options: [DropdownModel] = []
        for item in items {
            options.append(DropdownModel(display: item))
        }
        return options
    }
}
