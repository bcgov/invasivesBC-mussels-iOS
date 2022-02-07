//
//  AppDelegate.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-28.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Realm
import RealmSwift
//import Firebase

class AppLogDataSource: NSObject, LoggerDataSource {
    var csvLogFileName: String = "app_logger.csv"
    var logFileName: String = "app_logger.txt"
    var maxSize: Int = 1024 * 1024 * 1
    var appNamePrefix: String = "Mussel-Inspect"
    var timeFormat: String = "dd-MMM-yy HH:mm:ss"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        migrateRealm()
        //////
        // Setup App Name
        SetAppName("Mussel-Inspect")
        // Setup Logger
        LoggerSetDataSource(AppLogDataSource())
        // Start Logging
        ApplicationLogger.defalutLogger.start()
        //////
        // Keyboard settings
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        print("documents = \(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)")
        // Begin Autosync change listener
        SyncService.shared.beginListener()
        // Crash Lytics
        //FirebaseApp.configure()
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        SyncService.shared.endListener()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        SyncService.shared.beginListener()
    }
    
    /// https://realm.io/docs/swift/latest/#migrations
    func migrateRealm() {
        guard let generatedSchemaVersion = generateAppIntegerVersion() else {
            return
        }
        
        let config = Realm.Configuration(schemaVersion: UInt64(generatedSchemaVersion),
                                         migrationBlock: { migration, oldSchemaVersion in
                                            // check oldSchemaVersion here, if we're newer call
                                            // a method(s) specifically designed to migrate to
                                            // the desired schema. ie `self.migrateSchemaV0toV1(migration)`
                                            if (oldSchemaVersion < 4) {
                                                // Nothing to do. Realm will automatically remove and add fields
                                            }
        },
                                         shouldCompactOnLaunch: { totalBytes, usedBytes in
                                            // totalBytes refers to the size of the file on disk in bytes (data + free space)
                                            // usedBytes refers to the number of bytes used by data in the file
                                            
                                            // Compact if the file is over 100MB in size and less than 50% 'used'
                                            let oneHundredMB = 100 * 1024 * 1024
                                            return (totalBytes > oneHundredMB) && (Double(usedBytes) / Double(totalBytes)) < 0.5
        })
        
        Realm.Configuration.defaultConfiguration = config
    }
    
    /// App ingeget version is same as local db version in appdelegate's migrateRealm()
    /// (Version * 10) + build
    ///
    /// - Returns: Integer representing application and local database version
    func generateAppIntegerVersion() -> Int? {
        // We get version and build numbers of app
        guard let infoDict = Bundle.main.infoDictionary, let version = infoDict["CFBundleShortVersionString"] as? String, let build = infoDict["CFBundleVersion"] as? String  else {
            return nil
        }
        
        // comvert tp integer
        let versionAsString = "\(version)".removeWhitespaces().replacingOccurrences(of: ".", with: "", options: NSString.CompareOptions.literal, range:nil)
        guard let intVersion = Int(versionAsString), let intBuild = Int(build.removeWhitespaces())  else {
            return nil
        }
        
        return intVersion * 10 + intBuild
    }
}

