//
//  SyncModalView.swift
//  ipad
//
//  Created by Williams, Andrea IIT:EX on 2019-11-06.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit
import Modal

class SyncModalView: ModalView, Theme {

    @IBOutlet weak var syncModalView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dividerView: UIView!

    
    public func initialize() {
        present()
        style()
    }
    
    private func style() {
        styleCard(layer: self.layer)
        titleLabel.textColor = Colors.primary
    }

}
