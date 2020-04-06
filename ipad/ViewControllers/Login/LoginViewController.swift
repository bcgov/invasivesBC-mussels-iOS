//
//  LoginViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-28.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class LoginViewController: BaseViewController {
    
    let signupURL: URL = URL(string: "https://www.bceid.ca/register/")!
    let forgotPasswordURL: URL = URL(string: "https://www.bceid.ca/clp/account_recovery.aspx")!
    var webURL: URL?
    
    // MARK: Outlets
    @IBOutlet weak var appTitle: UILabel!
    @IBOutlet weak var loginWithIdirButton: UIButton!
    @IBOutlet weak var loginWithBCeIDButton: UIButton!
    @IBOutlet weak var loginContainer: UIView!
    
    // MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? WebKitViewController, let url = webURL else {return}
        destination.setInitial(url: url)
    }
    
    // MARK: Outlet Actions
    @IBAction func loginWithIdirAction(_ sender: UIButton) {
        AuthenticationService.refreshEnviormentConstants(withIdpHint: "idir")
        Settings.shared.setAuth(type: .Idir)
        AuthenticationService.authenticate { (success) in
            if (!success) {
                AuthenticationService.logout()
                return
            }
            self.afterLogin()
        }
    }
    
    @IBAction func loginWithBCeIDAction(_ sender: UIButton) {
//        AuthenticationService.refreshEnviormentConstants(withIdpHint: "bceid")
//        Settings.shared.setAuth(type: .BCeID)
//        AuthenticationService.authenticate { (success) in
//            if (!success) {
//                AuthenticationService.logout()
//                return
//            }
//            self.afterLogin()
//        }
        let dummyLogin: LoginView = UIView.fromNib()
        dummyLogin.setFixed(width: 400, height: 550)
        dummyLogin.present()
        dummyLogin.style()
        dummyLogin.setup(onForgotPassword: { [weak self] in
            guard let _self = self else {return}
            _self.webURL = _self.forgotPasswordURL
            dummyLogin.remove()
            _self.performSegue(withIdentifier: "showWebView", sender: self)
        }) {[weak self] in
            guard let _self = self else {return}
            _self.webURL = _self.signupURL
            dummyLogin.remove()
            _self.performSegue(withIdentifier: "showWebView", sender: self)
        }
    }
    
    private func afterLogin() {
        Settings.shared.setUserAuthId()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Style
    private func style() {
        setAppTitle(label: appTitle, darkBackground: false)
        styleFillButton(button: loginWithIdirButton)
        styleFillButton(button: loginWithBCeIDButton)
        styleCard(layer: loginContainer.layer)
    }
}
