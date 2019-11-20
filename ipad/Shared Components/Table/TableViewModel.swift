//
//  TableViewModel.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-20.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import UIKit

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
    var fields: [TableViewFieldModel] = []
    
    init(fields: [TableViewFieldModel]) {
        self.fields = fields
    }
}

class TableViewModel {
    var rows: [TableViewRowModel]
    
    // Headers and sizes
    var columns: [String: CGFloat]
    
    // Sorted headers
    var headers: [String]
    
    init(rows: [TableViewRowModel], columns: [String: CGFloat], headers: [String]) {
        self.rows = rows
        self.columns = columns
        self.headers = headers
    }
}
