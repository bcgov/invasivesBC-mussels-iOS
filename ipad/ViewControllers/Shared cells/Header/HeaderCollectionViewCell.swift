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
    @IBOutlet weak var button: UIButton!
    
    private var callback: (() -> Void)?
    
    func setup(with title: String, buttonName: String? = nil, buttonIcon: String? = nil, onButtonClick: (()->Void)? = nil) {
        self.titleLabel.text = title
        button.alpha = 0
        if let btnName = buttonName {
            button.setTitle(btnName, for: .normal)
            button.alpha = 1
        }
        if let iconName = buttonIcon, let image = UIImage(systemName: iconName) {
            button.setImage(image, for: .normal)
            button.alpha = 1
        }
        self.callback = onButtonClick
        style()
    }
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        guard let callback = self.callback else {return}
        return callback()
    }
    
    private func style() {
        styleHollowButton(button: button)
        styleSectionTitle(label: titleLabel)
    }
}
