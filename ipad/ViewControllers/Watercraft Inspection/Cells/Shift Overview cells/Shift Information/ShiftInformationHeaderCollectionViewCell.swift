//
//  ShiftInformationHeaderCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-21.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class ShiftInformationHeaderCollectionViewCell: UICollectionViewCell, Theme {
    
    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var hideButton: UIButton!
    @IBOutlet weak var divider: UIView!
    
    // MARK: Variables
    var completion: (()-> Void)?
    
    // MARK: Setup
    func setup(isHidden: Bool, onHide: @escaping ()-> Void) {
        self.completion = onHide
        let buttonTitle = isHidden ? "Show" : "Hide"
        hideButton.setTitle( buttonTitle, for: .normal)
        style()
    }
    
    // MARK: Outlet Actions
    @IBAction func hideButtonClicked(_ sender: UIButton) {
        guard let onHide = self.completion else {return}
        return onHide()
    }
    
    // MARK: Style
    func style() {
        styleSectionTitle(label: titleLabel)
        self.hideButton.setTitleColor(Colors.Status.DarkGray, for: .normal)
    }
}
