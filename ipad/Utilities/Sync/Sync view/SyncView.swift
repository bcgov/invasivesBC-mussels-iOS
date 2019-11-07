//
//  SyncView.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-04.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit
import Modal

class SyncView: ModalView, Theme {
    
    @IBOutlet weak var syncModal: UIView!
 
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var syncImageView: UIImageView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusIconView: UIImageView!
    @IBOutlet weak var hollowButton: UIButton!
    @IBOutlet weak var dividerView: UIView!
    
    public func initialize() {
        setFixed(width: 400, height: 390)
        style()
        present()
    }
    
    private func style() {
        styleCard(layer: self.layer)
        titleLabel.textColor = Colors.primary
        styleDividerGrey(view: dividerView)
    }
    
    private func setStatusLabel() {
        
    }
    
    private func setHollowButton() {
    }
    
    

}
