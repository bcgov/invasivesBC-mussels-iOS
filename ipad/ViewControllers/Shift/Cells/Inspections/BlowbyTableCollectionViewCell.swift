//
//  InspectionsTableCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-21.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class BlowbyTableCollectionViewCell: BaseShiftOverviewCollectionViewCell {
    
    // MARK: Constants
    static let maxVisibleRows: CGFloat = 4
    
    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var tableContainer: UIView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var blowByButton: UIButton!;
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
    
    @IBAction func addBlowbyClicked(_ sender: UIButton) {
        if let callback = self.completion {
            return callback()
        }
    }
    // MARK: Setup
    override func autofill() {
        guard let model = self.model else {return}
        let table = Table()
        
        // Convert list to array
        let blowbys: [BlowbyModel] = model.blowbys.map{ $0 }
        
        // Set table container height
        tableHeightConstraint.constant = BlowbyTableCollectionViewCell.getTableHeight(for: model)
                
        // Create Column Config
        var columns: [TableViewColumnConfig] = []
        columns.append(TableViewColumnConfig(key: "reportedToRapp", header: "Reported to Rapp", type: .Normal))
        columns.append(TableViewColumnConfig(key: "watercraftComplexity", header: "Watercraft Complexity", type: .Normal))
        columns.append(TableViewColumnConfig(key: "blowByTime", header: "Blowby Time", type: .Normal))
        columns.append(TableViewColumnConfig(key: "", header: "Delete", type: .Button, buttonName: "Delete", showHeader: false))
        let tableView = table.show(columns: columns, in: blowbys, container: tableContainer, emptyTitle: "It's looking a little empty around here.", emptyMessage: "You have not added any blowbys to this shift.")
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
        if model.blowbys.isEmpty {
            return 250
        }
        // Convert list to array
        
        let blowbys: [BlowbyModel] = model.blowbys.map{ $0 }
        let numberOfRows = blowbys.count
        
        let rowHeight = Table.rowHeight
        let headerHeight = Table.headerLabelHeight
        
        if numberOfRows < 1 {
            return headerHeight
        }
        
        // TODO: FIX IT
        let extraDEBUG: CGFloat = 20
        
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
