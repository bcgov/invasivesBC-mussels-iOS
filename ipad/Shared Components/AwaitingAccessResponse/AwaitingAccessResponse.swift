//
//  AwaitingAccessResponse.swift
//  ipad
//
//  Created by Amir Shayegh on 2020-02-24.
//  Copyright © 2020 Amir Shayegh. All rights reserved.
//

import UIKit

class AwaitingAccessResponse: UIView, Theme {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    func show(in container: UIView) {
        self.frame = container.bounds
        container.addSubview(self)
        addEqualSizeContraints(to: self, from: container)
        style()
    }
    
    func style() {
        styleAppTitle(label: headerLabel)
        styleSubHeader(label: messageLabel)
        headerLabel.textColor = Colors.primary
        messageLabel.textColor = Colors.primary
    }
}
