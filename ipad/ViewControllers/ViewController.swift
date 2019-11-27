//
//  ViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-28.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentNext()
    }
    
    private func presentNext() {
        if (!Auth.isAuthenticated()) {
            performSegue(withIdentifier: "performLogin", sender: nil)
            return
        } else {
            Auth.getUserFirstName()
            if AutoSync.shared.shouldPerformInitialSync() {
                AutoSync.shared.performInitialSync { (success) in
                    if success {
                        self.performSegue(withIdentifier: "showHomePage", sender: nil)
                    } else {
                        Alert.show(title: "Can't continue", message: "On your first login, we need to download some information.\nMake sure you have a stable connection")
                        Auth.logout()
                    }
                }
            } else {
                self.performSegue(withIdentifier: "showHomePage", sender: nil)
            }
        }
    }
}

