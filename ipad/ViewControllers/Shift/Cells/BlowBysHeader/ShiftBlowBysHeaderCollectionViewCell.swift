//
//  ShiftBlowBysHeaderCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-21.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class ShiftBlowBysHeaderCollectionViewCell: BaseShiftOverviewCollectionViewCell {

    // MARK: Outlets
    @IBOutlet weak var addBlowByButton: UIButton!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func autofill() {
        guard let model = self.model else {return}
        let remoteId: String = model.remoteId > 1 ? "\(model.remoteId) - " : ""
        if model.getStatus() != .Draft {
            addBlowByButton.alpha = 0
            addBlowByButton.isEnabled = false
        }
    }
    
    // MARK: Outlet Actions
    @IBAction func addBlowByClicked(_ sender: UIButton) {
        if let callback = self.completion {
            return callback()
        }
    }
    
    // MARK: Style
    override func style() {
        // Title
        titleLabel.font = Fonts.getPrimaryBold(size: 24)
        titleLabel.textColor = Colors.primary
        // Button
        styleFillButton(button: addBlowByButton)
        // Divider
        styleDivider(view: divider)
    }
    
    private func colorFor(status: SyncableItemStatus) -> UIColor {
        switch status {
        case .PendingSync:
            return Colors.Status.Yellow
        case .Completed:
            return Colors.Status.Green
        case .Draft:
            return Colors.Status.DarkGray
        }
    }
}
