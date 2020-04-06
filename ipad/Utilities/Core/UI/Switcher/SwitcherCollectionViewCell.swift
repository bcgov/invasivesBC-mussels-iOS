//
//  SwitcherCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-31.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class SwitcherCollectionViewCell: UICollectionViewCell, Theme {
    
    // MARK: Outlets
    @IBOutlet weak var button: UIButton!
    
    // MARK: Variables
    var callBack: (() -> Void )?
    var isActive: Bool = false
    
    // MARK: Constants
    let activeColor = Colors.secondary
    let inActiveColor = Colors.bodyText

    // MARK: Class func
    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        if let callback = self.callBack {
            return callback()
        }
    }
    
    // MARK: Functions
    public func setup(title: String, isActive: Bool, onClick: @escaping ()-> Void) {
        self.button.setTitle(title, for: .normal)
        self.callBack = onClick
        self.isActive = isActive
        style()
    }
    
    private func style() {
        if isActive {
            button.setTitleColor(activeColor, for: .normal)
        } else {
            button.setTitleColor(inActiveColor, for: .normal)
        }
        
        if let buttonLabel = button.titleLabel {
            buttonLabel.font = getSwitcherFont()
        }
    }

}
