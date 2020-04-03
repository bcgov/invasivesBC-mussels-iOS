//
//  DropdownTableViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-29.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class DropdownTableViewCell: UITableViewCell {

    var object: DropdownModel?

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var checkIcon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        if let obj = object {
            label.text = obj.display
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setup(object: DropdownModel, bg: UIColor) {
        self.object = object
        if label != nil {
            label.text = object.display
        }
        self.label.font = Fonts.getPrimary(size: 17)
        self.backgroundColor = bg
    }

    func select() {
        checkIcon.alpha = 1
    }

    func deSelect() {
        checkIcon.alpha = 0
    }
}
