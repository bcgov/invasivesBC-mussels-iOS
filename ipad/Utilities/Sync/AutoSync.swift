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
    private var isAutoSyncEnabled: Bool = true
    private var realmNotificationToken: NotificationToken?
    private var isSynchronizing: Bool = false
    private var manualSyncRequiredShown = false
    
    private init() {}
    
    // MARK: AutoSync Listener
    public func beginListener() {
        
        print("Listening to database changes in AutoSync.")
        if isOnline() {
            self.autoSynchronizeIfPossible()
        }
        do {
            let realm = try Realm()
            self.realmNotificationToken = realm.observe { notification, realm in
                print("Change observed in AutoSync...")
                if self.isOnline() && self.isAutoSyncEnabled {
                    self.autoSynchronizeIfPossible()
                }
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
    
    private func isOnline() -> Bool {
        do {
            let reachability = try Reachability()
            if reachability.connection == .unavailable {
                return false
            }
        } catch let error as NSError {
            print("** Reachability ERROR")
            print(error)
            return false
        }
        return true
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
        
        let itemsToSync = Storage.shared.itemsToSync()
        ShiftService.shared.submit(shifts: itemsToSync) { (syncSuccess) in
            if syncSuccess {
                Banner.show(message: "Sync Executed")
                NotificationCenter.default.post(name: .syncExecuted, object: nil)
            } else {
                Banner.show(message: "Could not sync items")
                self.isAutoSyncEnabled = false
            }
            // Remove SyncView
            syncView.remove()
            // Free Autosync
            self.isSynchronizing = false
        }
       
        /* Non Recursive solution
        // move to a background thread
        DispatchQueue.global(qos: .background).async {
            let dispatchGroup = DispatchGroup()
            var hadErros = false
            let itemsToSync = Storage.shared.itemsToSync()
            for item in itemsToSync {
                let itemId = item.localId
                dispatchGroup.enter()
                ShiftService.shared.submit(shift: item) { (success) in
                    if success, let refetchedShift = Storage.shared.shift(withLocalId: itemId) {
                        refetchedShift.set(shouldSync: false)
                        refetchedShift.set(status: .Completed)
                        for inspection in refetchedShift.inspections {
                            inspection.set(shouldSync: false)
                            inspection.set(status: .Completed)
                        }
                    } else {
                        hadErros = true
                        Banner.show(message: "Could not sync items")
                    }
                    dispatchGroup.leave()
                }
            }
 
            
            // dispatchGroup.enter()
            // Make another api call
            // dispatchGroup.leave()
            
            // End
            dispatchGroup.notify(queue: .main) {
                print("Autosync Executed.")
                print("AutoSync Success: \(!hadErros)")
                // remove the view
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    Banner.show(message: "Sync Executed")
                    NotificationCenter.default.post(name: .syncExecuted, object: nil)
                    syncView.remove()
                    // free autosync
                    self.isSynchronizing = false
                }
            }
        }*/
    }
    
    // MARK: Initial Sync
    public func performInitialSync(completion: @escaping(_ success: Bool) -> Void) {
        
        // Criteria passes
        if !shouldPerformInitialSync() {
            return completion(false)
        }
        
        // Block autosync from being executed.
        self.isSynchronizing = true
        self.endListener()
        // Add the autosync view
        let syncView: SyncView = UIView.fromNib()
        syncView.initialize()
        syncView.showSyncInProgressAnimation()
        syncView.set(title: "Performing Initial Sync")
        
        var hadErrors: Bool = false
        
        // move to a background thread
        DispatchQueue.global(qos: .background).async {

            let dispatchGroup = DispatchGroup()

            // Fetch code tables
            dispatchGroup.enter()
            CodeTables.shared.fetchCodes(completion: { (success) in
                if !success {
                    hadErrors = true
                    Banner.show(message: "Could not fetch code tables")
                }
                dispatchGroup.leave()
            }) { (statusUpdate) in
                syncView.set(status: statusUpdate)
            }

            // End
            dispatchGroup.notify(queue: .main) {
                print("Initial Sync Executed.")
                if !hadErrors {
                    syncView.set(status: "Completed")
                    syncView.showSyncCompletedAnimation()
                } else {
                    syncView.set(status: "Failed")
                    syncView.showSyncFailedAnimation()
                }
                // remove the view
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    syncView.remove()
                    // free autosync
                    self.isSynchronizing = false
                    self.beginListener()
                    return completion(!hadErrors)
                }
            }
        }
    }
    
    // MARK: Criteria
    public func shouldPerformInitialSync() -> Bool {
        // Is Online
        do {
            let reachability = try Reachability()
            if reachability.connection == .unavailable {
                return false
            }
        } catch let error as NSError {
            print("** Reachability ERROR")
            print(error)
            return false
        }
        
        // Code tables dont exist
        if Storage.shared.codeTables().count > 0 && Storage.shared.fullWaterBodyTables().count > 5000 {
            return false
        }
        
        // Is Authenticated
        if !Auth.isAuthenticated() {
            Alert.show(title: "Authentication Required", message: "You need to authenticate to perform the initial sync.\n Would you like to authenticate now and synchronize?\n\nIf you select no, You will not be able to create records.\n", yes: {
                switch Settings.shared.getAuthType() {
                case .Idir:
                    Auth.refreshEnviormentConstants(withIdpHint: "idir")
                case .BCeID:
                    Auth.refreshEnviormentConstants(withIdpHint: "bceid")
                }
                Auth.authenticate(completion: { (success) in
                    if success {
                        self.autoSynchronizeIfPossible()
                    }
                })
            }) {
                self.isEnabled = false
            }
            return false
        }
        
        return true
    }
    
    public func shouldSync() -> Bool {
        if !self.isEnabled { return false }
        if Storage.shared.itemsToSync().count < 1 {
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
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
}
