//
//  HighRiskModalView.swift
//  ipad
//
//  Created by Williams, Andrea IIT:EX on 2019-11-04.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit
import Modal

class HighRiskModalView: ModalView, Theme {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topDividerView: UIView!
    @IBOutlet weak var bottomDividerView: UIView!
    
    @IBOutlet weak var checkmarkImage: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    var onSubmit: (() -> Void)?
    var onCancel: (() -> Void)?
    
    @IBAction func confirmAction(_ sender: UIButton) {
        guard let onClick = self.onSubmit else {
            return
        }
        self.remove()
        return onClick()
        
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        guard let onClick = self.onCancel else {
            return
        }
        self.remove()
        return onClick()
    }
    
    public func initialize(onSubmit: @escaping () -> Void, onCancel:  @escaping () -> Void) {
        self.onSubmit = onSubmit
        self.onCancel = onCancel
        setFixed(width: 550, height: 285)
        present()
        style()
    }
    
    private func style() {
        styleCard(layer: self.layer)
        styleHollowButton(button: backButton)
        styleFillButton(button: confirmButton)
        styleDividerGrey(view: topDividerView)
        styleDividerGrey(view: bottomDividerView)
        titleLabel.textColor = Colors.primary
    }
    
}
