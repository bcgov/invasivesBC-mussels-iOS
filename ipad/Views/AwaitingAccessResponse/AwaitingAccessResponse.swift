//
//  AwaitingAccessResponse.swift
//  ipad
//
//  Created by Amir Shayegh on 2020-02-24.
//  Copyright © 2020 Amir Shayegh. All rights reserved.
//

import UIKit

class AwaitingAccessResponse: UIView, Theme {
    
    // MARK: Variables
    private var onRefreshCallback: (()->Void)?

    // MARK: Outlets
    @IBOutlet weak var refreshAccess: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: Outlet Actions
    @IBAction func refreshAction(_ sender: UIButton) {
        if let callback = onRefreshCallback {
            callback()
        }
    }
    
    // MARK: Setup
    func show(in container: UIView, onRefresh: @escaping()-> Void) {
        self.frame = container.bounds
        container.addSubview(self)
        addEqualSizeContraints(to: self, from: container)
        style()
        onRefreshCallback = onRefresh
    }
    
    // MARK: Style
    func style() {
        styleAppTitle(label: headerLabel)
        styleSubHeader(label: messageLabel)
        headerLabel.textColor = Colors.primary
        messageLabel.textColor = Colors.primary
    }
}
