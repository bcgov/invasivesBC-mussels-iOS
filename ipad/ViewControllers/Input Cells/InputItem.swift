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
    case Int
    case Double
    case Date
}

enum InputItemWidthSize {
    case Full
    case Half
    case Third
    case Forth
}

struct InputValue {
    var boolean: Bool?
    var string: String?
    var date: Date?
    var int: Int?
    var double: Double?
    
    func get(type: InputItemType) -> Any? {
        switch type {
        case .Dropdown:
            return self.string
        case .Text:
            return self.string
        case .Int:
            return self.int
        case .Double:
            return self.double
        case .Date:
            return self.date
        }
    }
    
    mutating func set(value: Any, type: InputItemType) {
        switch type {
        case .Dropdown:
            self.string = value as? String
        case .Text:
            self.string = value as? String
        case .Int:
            self.int = value as? Int
        case .Double:
            self.double = value as? Double
        case .Date:
            self.date = value as? Date
        }
    }
}

protocol InputItem {
    var type: InputItemType { get set }
    var width: InputItemWidthSize { get set }
    var height: CGFloat { get set }
    var key: String { get set }
    var value: InputValue { get set }
    var editable: Bool { get set }
}

protocol StringInputItem: InputItem {
    var value: String? {get set}
}

class DropdownInput: InputItem {
    var value: InputValue
    
    var type: InputItemType
    var width: InputItemWidthSize
    var height: CGFloat = 70
    var key: String
    var editable: Bool

    var dropdownItems: [DropdownModel] = []
    var header: String
    
    init(type: InputItemType, key: String, header: String, editable: Bool, value: String? = "", width: InputItemWidthSize? = .Full, dropdownItems: [DropdownModel]? = []) {
        self.value = InputValue()
        self.value.set(value: value ?? "", type: type)
        self.type = type
        self.key = key
        self.header = header
        self.editable = editable
        
        self.width = width ?? .Full
        self.dropdownItems = dropdownItems ?? []
    }
}

//class InputItemm {
//    var type: InputItemType
//    var key: String
//    var header: String
//    var value: String?
//    var editable: Bool
//    var width: InputItemWidthSize
//    var height: CGFloat = 70
//    
//    var dropdownItems: [DropdownModel] = []
//    
//    init(type: InputItemType, key: String, header: String, editable: Bool, value: String? = "", width: InputItemWidthSize? = .Full, dropdownItems: [DropdownModel]? = []) {
//        self.type = type
//        self.key = key
//        self.header = header
//        self.editable = editable
//        self.value = value
//        self.width = width ?? .Full
//        self.dropdownItems = dropdownItems ?? []
//    }
//}
