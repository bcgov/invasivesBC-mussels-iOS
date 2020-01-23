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
    
    // MARK: Class functions
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        // Specify you want _full width_
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        // Calculate the size (height) using Auto Layout
        let autoLayoutSize = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultHigh)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: autoLayoutSize)

        // Assign the new size to the layout attributes
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
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
        columns.append(TableViewColumnConfig(key: "inspectionTime", header: "Time Added", type: .Normal))
        columns.append(TableViewColumnConfig(key: "status", header: "Status", type: .WithIcon))
        columns.append(TableViewColumnConfig(key: "status", header: "Actions", type: .Button, buttonName: "View", showHeader: false))
        let tableView = table.show(columns: columns, in: inspections, container: tableContainer)
        tableView.layoutIfNeeded()
        self.layoutIfNeeded()
    }
    
    static func getContentHeight(for model: ShiftModel) -> CGFloat {
        let titleHeight: CGFloat = 25
        let dividerHeight: CGFloat = 2
        let paddings: CGFloat = 8 * 4
        let totalVertialTitleSize = titleHeight + dividerHeight + paddings
        return getTableHeight(for: model) + totalVertialTitleSize
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
        
        // TODO: FIX IT
        let extraDEBUG: CGFloat = 10
        
        if CGFloat(numberOfRows) > maxVisibleRows {
            return ( maxVisibleRows * (rowHeight + extraDEBUG)) + headerHeight + extraDEBUG
        } else {
            return ( CGFloat(numberOfRows) * (rowHeight + extraDEBUG)) + headerHeight + extraDEBUG
        }
    }
    
    // MARK: Style
    override func style() {
        styleSectionTitle(label: titleLabel)
        styleDivider(view: divider)
    }
    
}
