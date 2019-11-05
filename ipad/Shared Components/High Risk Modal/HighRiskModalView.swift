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
    
    var completion: (() -> Void)?
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    @IBAction func confirmAction(_ sender: UIButton) {
        guard let onClick = self.completion else {
            return
        }
        self.remove()
        return onClick()
        
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.remove()
    }
    
    
    public func initialize(onSubmit: @escaping () -> Void) {
        self.completion = onSubmit
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
//        checkmarkImage.image = UIImage(named: "../../Assets.xcassets/checkmarkIcon")
    }
    
}
