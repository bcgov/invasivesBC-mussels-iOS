//
//  OptionsTableViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-29.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class OptionsTableViewCell: UITableViewCell, Theme {

    // MARK: Variables
    var option: OptionType?

    // MARK: Outlets
    @IBOutlet weak var label: UILabel!
    
    // MARK: Cell functions
    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }

    // MARK: Setup
    func setup(option: OptionType) {
        self.option = option
        switch option {
        case .Delete:
            self.label.text = "Delete"
        case .Copy:
            self.label.text = "Copy"
        case .Logout:
            self.label.text = "Logout"
        case .ReportAnIssue:
            self.label.text = "Report an issue"
        case .RefreshContent:
            self.label.text = "Refresh Content"
        }
        style()
    }

    // MARK: Style
    func style() {
        label.adjustsFontSizeToFitWidth = true
        if let optionType = self.option, optionType == .Delete {
            label.textColor = Colors.warn
            label.font = Fonts.getPrimaryMedium(size: 15)
        } else {
            label.textColor = Colors.primary
            label.font = Fonts.getPrimaryMedium(size: 15)
        }
        
       
    }
}
