//
//  TableEmptyStateTableViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2020-03-12.
//  Copyright © 2020 Amir Shayegh. All rights reserved.
//

import UIKit

class TableEmptyStateTableViewCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    
    func setup(message: String) {
        self.messageLabel.text = message
        messageLabel.font = Fonts.getPrimaryMedium(size: 17)
    }
    
}
