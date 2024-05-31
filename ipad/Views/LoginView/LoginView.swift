//
//  LoginView.swift
//  ipad
//
//  Created by Amir Shayegh on 2020-04-03.
//  Copyright © 2020 Amir Shayegh. All rights reserved.
//

import UIKit
import Modal

class LoginView: ModalView, Theme {
    
    var onForgotPassword: (() -> Void)?
    var onSignUp: (() -> Void)?
    
    @IBOutlet weak var usernameHeader: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordHeader: UILabel!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    
    @IBAction func ContinueAction(_ sender: UIButton) {
        guard let password = passwordField.text, let username = usernameField.text else {
            return
        }
        
        if password.isEmpty || username.isEmpty {
            Alert.show(title: "Invalid Credentials", message: "Please enter valid credentials")
            return
        }
        
        resignFirstResponder()
        continueButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Alert.show(title: "Could not authenticate", message: "Please check the information you've entered")
            self.continueButton.isEnabled = true
        }
    }
    
    @IBAction func forgotPasswordAction(_ sender: Any) {
        guard let _ = URL(string: "https://www.bceid.ca/clp/account_recovery.aspx"), let callback = onForgotPassword else { return }
//        UIApplication.shared.open(url)
        callback()
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        guard let _ = URL(string: "https://www.bceid.ca/register/"), let callback = onSignUp else { return }
//        UIApplication.shared.open(url)
        callback()
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.remove()
    }
    
    func setup(onForgotPassword: @escaping ()-> Void, onSignUp: @escaping() -> Void) {
        self.onSignUp = onSignUp
        self.onForgotPassword = onForgotPassword
    }
    
    public func style() {
        styleInput(field: usernameField, header: usernameHeader, editable: true)
        styleInput(field: passwordField, header: passwordHeader, editable: true)
        styleFillButton(button: continueButton)
        passwordField.textContentType = .password
        usernameField.textContentType = .username
        passwordField.isSecureTextEntry = true
        roundCorners(layer: self.layer)
    }
    
}
