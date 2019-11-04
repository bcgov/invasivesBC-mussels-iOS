//
//  AppDelegate.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-28.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Keyboard settings
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        // Begin Autosync change listener
        AutoSync.shared.beginListener()
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        AutoSync.shared.endListener()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        AutoSync.shared.beginListener()
    }
}

