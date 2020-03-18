//
//  ViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-28.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit
import Reachability

class ViewController: UIViewController, Theme {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentNext()
    }
    
    private func presentNext() {
        if (!isAuthenticated()) {
            showLoginPage()
            return
        } else {
            AccessService.shared.hasAccess { [weak self] (hasAccess) in
                guard let strongSelf = self else {return}
                if hasAccess {
                    strongSelf.showHomePage()
                } else {
                    strongSelf.showPendingAccess()
                }
            }
        }
    }
    
    private func showLoginPage() {
        performSegue(withIdentifier: "performLogin", sender: nil)
    }
    
    private func showPendingAccess() {
        let awaitingAccessResponseView: AwaitingAccessResponse = UIView.fromNib()
        awaitingAccessResponseView.show(in: self.view)
    }
    
    private func showHomePage() {
        if !AutoSync.shared.shouldPerformInitialSync() {
            self.performSegue(withIdentifier: "showHomePage", sender: nil)
            return
        }
        AutoSync.shared.performInitialSync { [weak self] (success) in
            guard let strongSelf = self else {return}
            if success {
                strongSelf.performSegue(withIdentifier: "showHomePage", sender: nil)
            } else {
                Alert.show(title: "Can't continue", message: "On your first login, we need to download some information.\nMake sure you have a stable connection")
                Auth.logout()
            }
        }
    }
    
    private func isAuthenticated() -> Bool {
        // 1) User has logged in
        if !Auth.isLoggedIn() {
            return false
        }
        
        // 2) We have stored user's Id
        guard let storedUserId = Settings.shared.getUserAuthId() else {
            Auth.logout()
            return false
        }
        
        if storedUserId.isEmpty {
            Auth.logout()
            return false
        }
        
        // 3) Connection
        do {
            let reacahbility = try Reachability()
            
            if (reacahbility.connection == .unavailable) {
                // 3.1) User is offline
                return true
            } else {
                // 3.2) User is Online and User's token is not expired
                return Auth.isAuthenticated()
            }
        } catch  let error as NSError {
            print("** Reachability ERROR")
            print(error)
            return false
        }
    }
}

