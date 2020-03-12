//
//  TableEmptyStateTableViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2020-03-12.
//  Copyright © 2020 Amir Shayegh. All rights reserved.
//

import UIKit

class TableEmptyStateTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    func setup(title: String, message: String, iconName: String) {
        self.messageLabel.text = message
        messageLabel.font = Fonts.getPrimaryMedium(size: 17)
        titleLabel.font = Fonts.getPrimaryBold(size: 22)
        if let icon = UIImage(systemName: iconName) {
            iconImageView.image = icon
        }
    }
    
}
