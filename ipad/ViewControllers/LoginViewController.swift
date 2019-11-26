//
//  LoginViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-28.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class LoginViewController: BaseViewController {

    @IBOutlet weak var appTitle: UILabel!
    @IBOutlet weak var loginWithIdirButton: UIButton!
    @IBOutlet weak var loginWithBCeIDButton: UIButton!
    @IBOutlet weak var loginContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
    }
    
    @IBAction func loginWithIdirAction(_ sender: UIButton) {
        Auth.refreshEnviormentConstants(withIdpHint: "idir")
        Auth.authenticate { (success) in
            if (success) {
                AutoSync.shared.performInitialSync { (success) in
                    if success {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        Auth.logout()
                    }
                }
               
            }
        }
    }
    
    @IBAction func loginWithBCeIDAction(_ sender: UIButton) {
        Auth.refreshEnviormentConstants(withIdpHint: "bceid")
        Auth.authenticate { (success) in
            if (success) {
                 self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func style() {
        setAppTitle(label: appTitle, darkBackground: false)
        styleFillButton(button: loginWithIdirButton)
        styleHollowButton(button: loginWithBCeIDButton)
        styleCard(layer: loginContainer.layer)
    }
    
}
