//
//  TableViewModel.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-20.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import UIKit

struct TableViewColumnConfig {
    var type: TableViewColumnType
    var key: String
    var header: String
    var buttonName: String
    var showHeader: Bool
    
    init(key: String, header: String, type: TableViewColumnType, buttonName: String? = "", showHeader: Bool? = true) {
        self.key = key
        self.header = header
        self.type = type
        self.buttonName = buttonName ?? ""
        self.showHeader = showHeader ?? true
    }
}

struct TableViewFieldModel {
    var header: String
    var value: String
    var iconColor: UIColor?
    var isButton: Bool = false
    
    init(header: String, value: String, iconColor: UIColor? = nil, isButton: Bool? = false) {
        self.header = header
        self.value = value
        self.iconColor = iconColor
        self.isButton = isButton ?? false
    }
}

struct TableViewRowModel {
    var object: Any
    var fields: [TableViewFieldModel] = []
    
    init(fields: [TableViewFieldModel], object: Any) {
        self.object = object
        self.fields = fields
    }
}

class TableViewModel {
    var rows: [TableViewRowModel]
    
    // Headers and sizes
    var columnSizes: [String: CGFloat]
    
    // Relative sizes (percentage)
    var relativeSizes: [String: CGFloat]
    
    // Sorted headers
    var headers: [String]
    
    // Displayed headers
    var displayedHeaders: [String]
    
    init(rows: [TableViewRowModel], columnSizes: [String: CGFloat], headers: [String], displayedHeaders: [String], relativeSizes: [String: CGFloat]) {
        self.rows = rows
        self.columnSizes = columnSizes
        self.headers = headers
        self.displayedHeaders = displayedHeaders
        self.relativeSizes = relativeSizes
    }
}
