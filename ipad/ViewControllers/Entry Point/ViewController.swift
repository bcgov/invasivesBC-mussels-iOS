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
    
    // MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // On viewDidLoad, Choose between presenting
        // Login ViewController
        // Or Home ViewController
        presentNext()
    }
    
    // MARK: Class Functions
    private func presentNext() {
        if (!isAuthenticated()) {
            segueToLoginPage()
            return
        }
        AccessService.shared.hasAccess { [weak self] (hasAccess) in
            guard let strongSelf = self else {return}
            if hasAccess {
                strongSelf.showHomePage()
            } else {
                strongSelf.showPendingAccess()
            }
        }
    }
    
    private func segueToLoginPage() {
        performSegue(withIdentifier: "performLogin", sender: nil)
    }
    
    private func segueToHomePage() {
        performSegue(withIdentifier: "showHomePage", sender: nil)
    }
    
    private func showPendingAccess() {
        let awaitingAccessResponseView: AwaitingAccessResponse = UIView.fromNib()
        awaitingAccessResponseView.show(in: self.view, onRefresh: { [weak self] in
            guard let _self = self else {return}
            awaitingAccessResponseView.removeFromSuperview()
            _self.presentNext()
        })
    }
    
    private func showHomePage() {
        if !SyncService.shared.shouldPerformInitialSync() {
            segueToHomePage()
            return
        }
        SyncService.shared.performInitialSync { [weak self] (success) in
            guard let _self = self else {return}
            if success {
                _self.segueToHomePage()
            } else {
                _self.onFailedLogin()
            }
        }
    }
    
    private func onFailedLogin() {
        Alert.show(title: "Can't continue", message: "On your first login, we need to download some information.\nMake sure you have a stable connection")
        AuthenticationService.logout()
    }
    
    // MARK: Auth check
    private func isAuthenticated() -> Bool {
        // 1) User has logged in
        if !AuthenticationService.isLoggedIn() {
            return false
        }
        
        // 2) We have stored user's Id
        guard let storedUserId = Settings.shared.getUserAuthId() else {
            AuthenticationService.logout()
            return false
        }
        
        if storedUserId.isEmpty {
            AuthenticationService.logout()
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
                return AuthenticationService.isAuthenticated()
            }
        } catch  let error as NSError {
            print("** Reachability ERROR")
            print(error)
            return false
        }
    }
}

