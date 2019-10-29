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
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        Auth.authenticate { (success) in
            if (success) {
                 self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func style() {
        setAppTitle(label: appTitle, darkBackground: false)
    }
    
}
