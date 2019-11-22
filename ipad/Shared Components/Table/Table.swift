//
//  Table.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-20.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import UIKit

enum TableViewColumnType {
    case Normal
    case Button
    case Counter
    case WithIcon
}

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

class Table {
    
    // MARK: Constants
    static let headerLabelHeight: CGFloat = 20.0
    static let headerFont = Fonts.getPrimaryBold(size: 17)
    
    static let rowHeight: CGFloat = 30.0
    static let fieldFont = Fonts.getPrimary(size: 17)
    
    static let indicatorSize: CGFloat = 16.0
    
    static let buttonPadding: CGFloat = 16.0
    
    static let rowItemSpacing: CGFloat = 0
    
    
    /// Initialization
    /// Create an array of TableViewColumnConfig to specify which variables from the objects shuld be displayed
    /// - Parameter keys: Array of keys to be displayed & how they should be displayed
    /// - Parameter objects: PropertyReflectable Objects to display in rows
    /// - Parameter container: Container to place table in
    public func show(columns: [TableViewColumnConfig], in objects: [PropertyReflectable], container: UIView) {
        // 1) Create models for Rows
        var counter = 0
        var rows: [TableViewRowModel] = []
        for object in objects {
            counter += 1
            var rowFields: [TableViewFieldModel] = []
            for column in columns {
                switch column.type {
                case .Normal:
                    if let value = object[column.key] {
                        rowFields.append(TableViewFieldModel(header: column.header, value: "\(value)"))
                    }
                case .Button:
                    rowFields.append(TableViewFieldModel(header: column.header, value: column.buttonName, isButton: true))
                case .Counter:
                    rowFields.append(TableViewFieldModel(header: column.header, value: "\(counter)"))
                case .WithIcon:
                    if let value = object[column.key] {
                        rowFields.append(TableViewFieldModel(header: column.header, value: "\(value)", iconColor: .red))
                    }
                }
            }
            rows.append(TableViewRowModel(fields: rowFields))
        }
        // 2) Create Headers
        let headers: [String] = rows.count > 0 ? rows[0].fields.map { $0.header } : []
        let displayedHeaders: [String] = columns.map{ $0.showHeader ? $0.header : ""}
        
        // 3) Create Column sizing
        var columnSizes: [String: CGFloat] = [String: CGFloat]()
        for header in headers {
            columnSizes[header] = findMaxLengthForColumn(header: header, in: rows)
        }
        let relativeSizing = computeRelativeSizing(for: columnSizes)
        
        // 4) Create Model
        let tableModel: TableViewModel = TableViewModel(
            rows: rows,
            columnSizes: columnSizes,
            headers: headers,
            displayedHeaders: displayedHeaders,
            relativeSizes: relativeSizing
        )
        
        // 5) Create tableview
        let tableView: TableView = TableView.fromNib()
        tableView.initialize(with: tableModel, in: container)
    }
    
    // MARK: Sizing
    private func computeRelativeSizing(for columnSizes: [String: CGFloat]) -> [String: CGFloat] {
        var percentSizes: [String: CGFloat] = [String: CGFloat]()
        var totalRequiredWidth: CGFloat = 0
        for (_, width) in columnSizes {
            totalRequiredWidth += width
            totalRequiredWidth += Table.rowItemSpacing
        }
        
        for (key, width) in columnSizes {
            percentSizes[key] = (width / totalRequiredWidth) * 100
        }
        
        return percentSizes
    }
    
    private func widthFor(column header: String) -> CGFloat {
        return header.width(withConstrainedHeight: Table.headerLabelHeight, font: Table.headerFont)
    }
    
    private func widthFor(field value: String) -> CGFloat {
        return value.width(withConstrainedHeight: Table.rowHeight, font: Table.fieldFont)
    }
    
    private func maxButtonWidth(for header: String, in rows: [TableViewRowModel]) -> CGFloat {
        var maxLength: CGFloat = 0
        for row in rows {
            for field in row.fields where field.isButton && field.header == header {
                let estimatedWidth = field.value.width(withConstrainedHeight: Table.rowHeight, font: Table.fieldFont)
                if estimatedWidth > maxLength {
                    maxLength = estimatedWidth
                }
            }
        }
        return maxLength + Table.buttonPadding
    }
    
    /// Find the width required to display tongest value in column
    /// - Parameter header: Column header
    /// - Parameter rows: All Rows
    private func findMaxLengthForColumn(header: String, in rows: [TableViewRowModel]) -> CGFloat {
        var max: CGFloat = widthFor(column: header)
        for row in rows {
            for field in row.fields where field.header == header {
                if field.isButton {
                    // TODO: Improve this, cant loop every time.. cache max button width
                    return maxButtonWidth(for: header, in: rows)
                }
                let width = widthFor(field: field.value)
                if width > max {
                    max = width
                }
            }
        }
        return max
    }
    
    // MARK: Test
    public func test(in container: UIView) {
        var columns: [TableViewColumnConfig] = []
        var objects: [TestTableViewObject] = []
        
        // Create Test Object
        let testObject1 = TestTableViewObject()
        testObject1.remoteId = 1001
        testObject1.timeAdded = "10:30pm"
        testObject1.status = "Pending"
        testObject1.riskLevel = "high"
        objects.append(testObject1)
        
        // Create Test 2
        let testObject2 = TestTableViewObject()
        testObject2.remoteId = 1002
        testObject2.timeAdded = "10:30pm"
        testObject2.status = "Draft"
        testObject2.riskLevel = "low"
        objects.append(testObject2)
        
        // Create Column Config
        columns.append(TableViewColumnConfig(key: "", header: "#", type: .Counter, showHeader: false))
        columns.append(TableViewColumnConfig(key: "remoteId", header: "ID", type: .Normal))
        columns.append(TableViewColumnConfig(key: "riskLevel", header: "Risk Level", type: .Normal))
        columns.append(TableViewColumnConfig(key: "timeAdded", header: "Time Added", type: .Normal))
        columns.append(TableViewColumnConfig(key: "status", header: "Status", type: .WithIcon))
        columns.append(TableViewColumnConfig(key: "", header: "Actions", type: .Button, buttonName: "View", showHeader: false))
        
        // Create table
        show(columns: columns, in: objects, container: container)
    }
}
