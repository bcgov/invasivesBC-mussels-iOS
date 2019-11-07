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
    case Switch
    case TextArea
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
    var itemId: String?
    
    func get(type: InputItemType) -> Any? {
        switch type {
        case .Dropdown:
            return self.itemId
        case .Text:
            return self.string
        case .Int:
            return self.int
        case .Double:
            return self.double
        case .Date:
            return self.date
        case .Switch:
            return self.boolean
        case .TextArea:
            return self.string
        }
    }
    
    mutating func set(value: Any?, type: InputItemType) {
        switch type {
        case .Dropdown:
            self.itemId = value as? String
        case .Text:
            self.string = value as? String
        case .Int:
            self.int = value as? Int
        case .Double:
            self.double = value as? Double
        case .Date:
            self.date = value as? Date
        case .Switch:
            self.boolean = value as? Bool
        case .TextArea:
            self.string = value as? String
        }
    }
}

protocol InputItem {
    var type: InputItemType { get set }
    var width: InputItemWidthSize { get set }
    var height: CGFloat { get set }
    var key: String { get set }
    var value: InputValue { get set }
    var header: String { get set }
    var editable: Bool { get set }
}

protocol StringInputItem: InputItem {
    var value: String? {get set}
}

class DropdownInput: InputItem {
    var value: InputValue
    
    var type: InputItemType = .Dropdown
    var width: InputItemWidthSize
    var height: CGFloat = 70
    var key: String
    var editable: Bool
    
    var dropdownItems: [DropdownModel] = []
    var header: String
    
    init(key: String, header: String, editable: Bool, value: String? = "", width: InputItemWidthSize? = .Full, dropdownItems: [DropdownModel]? = []) {
        self.value = InputValue()
        self.value.set(value: value ?? "", type: type)
        self.key = key
        self.header = header
        self.editable = editable
        self.width = width ?? .Full
        self.dropdownItems = dropdownItems ?? []
    }
    
    func getValue() -> String {
        return self.value.get(type: self.type) as? String ?? ""
    }
    
    func setValue(value: String) {
        self.value.get(type: self.type)
    }
}

class TextInput: InputItem {
    var type: InputItemType = .Text
    var width: InputItemWidthSize
    var height: CGFloat = 70
    var key: String
    var value: InputValue
    var editable: Bool
    var header: String
    
    init(key: String, header: String, editable: Bool, value: String? = "", width: InputItemWidthSize? = .Full) {
        self.value = InputValue()
        self.value.set(value: value, type: type)
        self.key = key
        self.header = header
        self.editable = editable
        self.width = width ?? .Full
    }
    
    func getValue() -> String {
        return self.value.get(type: self.type) as? String ?? ""
    }
    
    func setValue(value: String) {
        self.value.get(type: self.type)
    }
}


class SwitchInput: InputItem {
    var type: InputItemType = .Switch
    var width: InputItemWidthSize
    var height: CGFloat = 70
    var key: String
    var value: InputValue
    var header: String
    var editable: Bool
    
    init(key: String, header: String, editable: Bool, value: Bool? = false, width: InputItemWidthSize? = .Full) {
        self.value = InputValue()
        self.value.set(value: value ?? false, type: type)
        self.key = key
        self.header = header
        self.editable = editable
        self.width = width ?? .Full
    }
    
    func getValue() -> Bool {
        return self.value.get(type: self.type) as? Bool ?? ""
    }
    
    func setValue(value: Bool) {
        self.value.get(type: self.type)
    }
}

class DateInput: InputItem {
    var type: InputItemType = .Date
    var width: InputItemWidthSize
    var height: CGFloat = 70
    var key: String
    var value: InputValue
    var header: String
    var editable: Bool
    
    init(key: String, header: String, editable: Bool, value: Date? = nil, width: InputItemWidthSize? = .Full) {
        self.value = InputValue()
        self.value.set(value: value, type: type)
        self.key = key
        self.header = header
        self.editable = editable
        self.width = width ?? .Full
    }
    
    func getValue() -> Date {
        return self.value.get(type: self.type) as? Date ?? ""
    }
    
    func setValue(value: Date) {
        self.value.get(type: self.type)
    }
}

class TextAreaInput: InputItem {
    var type: InputItemType = .TextArea
    var width: InputItemWidthSize
    var height: CGFloat = 200
    var key: String
    var value: InputValue
    var header: String
    var editable: Bool
    
    init(key: String, header: String, editable: Bool, value: String? = nil, width: InputItemWidthSize? = .Full) {
        self.value = InputValue()
        self.value.set(value: value, type: type)
        self.key = key
        self.header = header
        self.editable = editable
        self.width = width ?? .Full
    }
}


class IntegerInput: InputItem {
    var type: InputItemType = .Int
    var width: InputItemWidthSize
    var height: CGFloat = 70
    var key: String
    var value: InputValue
    var header: String
    var editable: Bool
    
    init(key: String, header: String, editable: Bool, value: Int? = nil, width: InputItemWidthSize? = .Full) {
        self.value = InputValue()
        self.value.set(value: value, type: type)
        self.key = key
        self.header = header
        self.editable = editable
        self.width = width ?? .Full
    }
}
