//
//  ShifOverviewHeaderCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-21.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class ShifOverviewHeaderCollectionViewCell: BaseShiftOverviewCollectionViewCell {

    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addInspectionButton: UIButton!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var numberAndDateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var statusIndicator: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func autofill() {
        guard let model = self.model else {return}
        self.numberAndDateLabel.text = "\(model.remoteId) - \(model.formattedDate)"
        self.locationLabel.text = model.location
        self.statusLabel.text = model.status
        self.statusIndicator.backgroundColor = StatusColor.color(for: model.status)
        if model.getStatus() != .Draft {
            addInspectionButton.alpha = 0
            addInspectionButton.isEnabled = false
        }
    }
    
    // MARK: Outlet Actions
    @IBAction func addInspectionClicked(_ sender: UIButton) {
        if let callback = self.completion {
            return callback()
        }
    }
    
    // MARK: Style
    override func style() {
        // Title
        titleLabel.font = Fonts.getPrimaryBold(size: 28)
        titleLabel.textColor = Colors.primary
        // Button
        styleFillButton(button: addInspectionButton)
        // Divider
        styleDivider(view: divider)
        // Status
        numberAndDateLabel.font = Fonts.getPrimary(size: 17)
        locationLabel.font = Fonts.getPrimary(size: 17)
        locationLabel.textColor = Colors.Status.DarkGray
        statusLabel.font = Fonts.getPrimary(size: 17)
        statusIndicator.backgroundColor = colorFor(status: model?.getStatus() ?? .Draft)
        makeCircle(view: statusIndicator)
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
