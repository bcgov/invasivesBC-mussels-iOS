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
        Settings.shared.setAuth(type: .Idir)
        Auth.authenticate { (success) in
            if (!success) {
                Auth.logout()
                return
            }
            self.afterLogin()
        }
    }
    
    @IBAction func loginWithBCeIDAction(_ sender: UIButton) {
        Auth.refreshEnviormentConstants(withIdpHint: "bceid")
        Settings.shared.setAuth(type: .BCeID)
        Auth.authenticate { (success) in
            if (!success) {
                Auth.logout()
                return
            }
            self.afterLogin()
        }
    }
    
    private func afterLogin() {
        Settings.shared.setUserAuthId()
        self.dismiss(animated: true, completion: nil)
//        if !AutoSync.shared.shouldPerformInitialSync() {
//            self.dismiss(animated: true, completion: nil)
//            return
//        }
//        AutoSync.shared.performInitialSync { (success) in
//            if (!success) {
//                Auth.logout()
//                return
//            }
//            self.dismiss(animated: true, completion: nil)
//        }
    }
    
    private func style() {
        setAppTitle(label: appTitle, darkBackground: false)
        styleFillButton(button: loginWithIdirButton)
        styleFillButton(button: loginWithBCeIDButton)
        styleCard(layer: loginContainer.layer)
    }
    
}
