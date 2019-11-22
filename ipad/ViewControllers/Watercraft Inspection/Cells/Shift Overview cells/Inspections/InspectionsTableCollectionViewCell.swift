//
//  InspectionsTableCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-21.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class InspectionsTableCollectionViewCell: BaseShiftOverviewCollectionViewCell {
    
    // MARK: Constants
    static let maxVisibleRows: CGFloat = 4
    
    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var tableContainer: UIView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    
    // MARK: Setup
    override func autofill() {
        guard let model = self.model else {return}
        
        let table = Table()
        
        // Convert list to array
        let inspections: [WatercradftInspectionModel] = model.inspections.map{ $0 }
        
        // Set table container height
        tableHeightConstraint.constant = InspectionsTableCollectionViewCell.getTableHeight(for: model)
        
        // Create Column Config
        var columns: [TableViewColumnConfig] = []
        columns.append(TableViewColumnConfig(key: "", header: "#", type: .Counter, showHeader: false))
        columns.append(TableViewColumnConfig(key: "remoteId", header: "ID", type: .Normal))
        columns.append(TableViewColumnConfig(key: "riskLevel", header: "Risk Level", type: .Normal))
        columns.append(TableViewColumnConfig(key: "timeAdded", header: "Time Added", type: .Normal))
        columns.append(TableViewColumnConfig(key: "status", header: "Status", type: .WithIcon))
        columns.append(TableViewColumnConfig(key: "", header: "Actions", type: .Button, buttonName: "View", showHeader: false))
        table.show(columns: columns, in: inspections, container: tableContainer)
    }
    
    static func getTableHeight(for model: ShiftModel) -> CGFloat {
        // Convert list to array
        let inspections: [WatercradftInspectionModel] = model.inspections.map{ $0 }
        let numberOfRows = inspections.count
        
        let rowHeight = Table.rowHeight
        let headerHeight = Table.headerLabelHeight
        
        if numberOfRows < 1 {
            return headerHeight
        }
        
        if CGFloat(numberOfRows) > maxVisibleRows {
            return ( maxVisibleRows * rowHeight) + headerHeight
        } else {
            return ( CGFloat(numberOfRows) * rowHeight) + headerHeight
        }
    }
    
    // MARK: Style
    override func style() {
        styleSectionTitle(label: titleLabel)
        styleDivider(view: divider)
    }
    
}
