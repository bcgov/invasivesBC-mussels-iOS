//
//  HeaderCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-05.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class HeaderCollectionViewCell: UICollectionViewCell, Theme {

    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(with title: String) {
        self.titleLabel.text = title
        style()
    }
    
    private func style() {
        styleSectionTitle(label: titleLabel)
    }
}
