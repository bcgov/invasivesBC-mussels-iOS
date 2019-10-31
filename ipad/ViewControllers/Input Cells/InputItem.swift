//
//  InputModel.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-31.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import UIKit

enum InputItemType {
    case Dropdown
    case Text
    case Number
    case Date
}

enum InputItemWidthSize {
    case Full
    case Half
    case Third
    case Forth
}

class InputItem {
    var type: InputItemType
    var key: String
    var header: String
    var value: String?
    var editable: Bool
    var width: InputItemWidthSize
    var height: CGFloat = 70
    
    var dropdownItems: [DropdownModel] = []
    
    init(type: InputItemType, key: String, header: String, editable: Bool, value: String? = "", width: InputItemWidthSize? = .Full, dropdownItems: [DropdownModel]? = []) {
        self.type = type
        self.key = key
        self.header = header
        self.editable = editable
        self.value = value
        self.width = width ?? .Full
        self.dropdownItems = dropdownItems ?? []
    }
}
