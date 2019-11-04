//
//  AutoSync.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-28.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import Reachability
import Realm
import RealmSwift
import Extended
import SingleSignOn

class AutoSync {
    
    internal static let shared = AutoSync()
    
    private var isEnabled: Bool = true
    private var realmNotificationToken: NotificationToken?
    private var isSynchronizing: Bool = false
    private var manualSyncRequiredShown = false
    
    private init() {}
    
    // MARK: AutoSync Listener
    public func beginListener() {
        
        print("Listening to database changes in AutoSync.")
        do {
            let realm = try Realm()
            self.realmNotificationToken = realm.observe { notification, realm in
                print("Change observed in AutoSync...")
                do {
                    let reachability = try Reachability()
                    if reachability.connection == .unavailable {
                        return
                    }
                } catch _ {return}
                self.autoSynchronizeIfPossible()
            }
        } catch _ {
            print("Error with db change listener")
        }
    }
    
    public func endListener() {
           if let token = self.realmNotificationToken {
               token.invalidate()
               print("Stopped listening to database changes in AutoSync.")
           }
       }
    
    private func autoSynchronizeIfPossible() {
        print("Checking if we can autosync...")
        if self.isSynchronizing {
            print("You're already synchronizing.")
            return
        }
        
        if !shouldSync() {
            print("can't sync right now")
            return
        }
        
        // Add other criteria
        
        // Perform sync if needed
        self.sync()
    }
   
    
    // MARK: sync Action
    public func sync() {
        if !shouldSync() {
            return
        }
        
         print("Executing Autosync...")
        
        // Block autosync from being re-executed.
        self.isSynchronizing = true
        
        // Add the autosync view
        let syncView: SyncView = UIView.fromNib()
        syncView.initialize()
        
        // move to a background thread
        DispatchQueue.global(qos: .background).async {
            
            
            let dispatchGroup = DispatchGroup()
            
            let itemsToSync = Storage.shared.getItemsToSync()
            if itemsToSync.count > 0 {
                dispatchGroup.enter()
                // Upload / sync etc
                dispatchGroup.leave()
            }
            
            dispatchGroup.enter()
            // Make another api call
            dispatchGroup.leave()
            
            
            // End
            dispatchGroup.notify(queue: .main) {
                print("Autosync Executed.")
                
                // remove the view
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    syncView.remove()
                    // free autosync
                    self.isSynchronizing = false
                }
            }
        }
    }
    
    // MARK: Criteria
    public func shouldSync() -> Bool {
        
        if Storage.shared.getItemsToSync().count < 1 {
            return false
        }
        
        if !Auth.isAuthenticated() {
            if !manualSyncRequiredShown {
                Alert.show(title: "Authentication Required", message: "You have items that need to be synced.\n Would you like to authenticate now and synchronize?\n\nIf you select no, Autosync will be turned off until the app is reopened.\n", yes: {
                    Auth.authenticate(completion: { (success) in
                        if success {
                            self.autoSynchronizeIfPossible()
                        }
                    })
                }) {
                    self.isEnabled = false
                }
            }
            return false
        }
        
        return true
    }
}
