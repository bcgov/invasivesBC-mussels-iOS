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

enum SyncValidation {
    case Ready
    case isOffline
    case AuthExpired
    case NothingToSync
    case NeedsAccess
    case SyncDisabled
}

class SyncService {
    
    internal static let shared = SyncService()
    
    private var isEnabled: Bool = true
    private var isAutoSyncEnabled: Bool = true
    private var realmNotificationToken: NotificationToken?
    private var isSynchronizing: Bool = false
    private var manualSyncRequiredShown = false
    
    private let syncView: SyncView = UIView.fromNib()
    
    private init() {}
    
    // MARK: AutoSync Listener
    public func beginListener() {
        
        print("Listening to database changes in AutoSync.")
        do {
            let realm = try Realm()
            self.realmNotificationToken = realm.observe { [weak self] notification, realm  in
                guard let strongSelf = self else { return }
                print("Change observed in AutoSync...")
                if strongSelf.isOnline() && strongSelf.isAutoSyncEnabled {
                    strongSelf.syncIfPossible()
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
    
    // MARK: sync
    public func syncIfPossible() {
        if self.isEnabled == false {return}
        print("Checking if we can autosync...")
        if self.isSynchronizing {
            print("You're already synchronizing.")
            return
        }
        
        canSync(completion: { (syncValidation) in
            if syncValidation != .Ready {
                print("can't sync right now")
                return
            } else {
                // Perform sync if needed
                self.performSync()
            }
        })
    }
    
    public func syncCodeTablesAndWaterBodiesIfPossible() {
        if self.isSynchronizing {
            print("Wait for Sync to finish")
            return
        }
        
        canReadFromApi { (validation) in
            if validation != .Ready {
                print("can't sync right now")
                return
            } else {
                // Perform sync if needed
                self.syncCodeTablesAndWaterBodies()
            }
        }
    }
    
    private func syncCodeTablesAndWaterBodies() {
        if isSynchronizing {return}
        // Block sync from being executed
        self.isSynchronizing = true
        self.endListener()
        // Add the autosync view
        syncView.initialize()
        syncView.showSyncInProgressAnimation()
        syncView.set(title: "Refreshing content")
        
        CodeTableService.shared.fetchCodes(completion: { (success) in
            if !success {
                Banner.show(message: "Could not fetch code tables")
                self.syncView.set(status: "Failed")
                self.syncView.showSyncFailedAnimation()
            } else {
                self.syncView.set(status: "Completed")
                self.syncView.showSyncCompletedAnimation()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.syncView.remove()
                // free autosync
                self.isSynchronizing = false
                self.beginListener()
            }
            
        }) {  [weak self] (statusUpdate) in
            guard let strongSelf = self else { return }
            strongSelf.syncView.set(status: statusUpdate)
        }
        
    }
    
    private func performSync() {
        if isSynchronizing {return}
        print("Executing Autosync...")
        // Block autosync from being re-executed.
        self.isSynchronizing = true
        
        // Add the autosync view
        self.syncView.initialize()
        let itemsToSync = Storage.shared.itemsToSync()
        ShiftService.shared.submit(shifts: itemsToSync) { (syncSuccess) in
            if syncSuccess {
                CodeTableService.shared.fetchAndStoreCodeTables(completion: { (updatedCodeTables) in
                    Banner.show(message: "Sync Executed")
                    NotificationCenter.default.post(name: .syncExecuted, object: nil)
                    self.syncView.remove()
                    // Free Autosync
                    self.isSynchronizing = false
                }) { (statusUpdate) in
                    print(statusUpdate)
                }
            } else {
                Banner.show(message: "Could not sync items")
                self.isAutoSyncEnabled = false
                // Remove SyncView
                // Delay added because the sync could fail faster than the view can finish displaying
                // with animations. calling remove before its done displaying will cause a crash.
                self.delayWithSeconds(1) {
                    self.syncView.remove()
                    // Free Autosync
                    self.isSynchronizing = false
                }
            }
        }
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
        syncView.initialize()
        syncView.showSyncInProgressAnimation()
        syncView.set(title: "Performing Initial Sync")
        
        var hadErrors: Bool = false
        
        // move to a background thread
        DispatchQueue.global(qos: .background).async {

            let dispatchGroup = DispatchGroup()

            // Fetch code tables
            dispatchGroup.enter()
            CodeTableService.shared.fetchCodes(completion: { (success) in
                if !success {
                    hadErrors = true
                    Banner.show(message: "Could not fetch code tables")
                }
                dispatchGroup.leave()
            }) {  [weak self] (statusUpdate) in
                guard let strongSelf = self else { return }
                strongSelf.syncView.set(status: statusUpdate)
            }

            // End
            dispatchGroup.notify(queue: .main) { [weak self] in
                guard let strongSelf = self else { return }
                print("Initial Sync Executed.")
                if !hadErrors {
                    strongSelf.syncView.set(status: "Completed")
                    strongSelf.syncView.showSyncCompletedAnimation()
                } else {
                    strongSelf.syncView.set(status: "Failed")
                    strongSelf.syncView.showSyncFailedAnimation()
                }
                // remove the view
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.syncView.remove()
                    // free autosync
                    strongSelf.isSynchronizing = false
                    strongSelf.beginListener()
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
        if Storage.shared.codeTables().count > 0 && WaterbodiesService.shared.get().count > 5000 {
            return false
        }
        
        // Is Authenticated
        if !AuthenticationService.isAuthenticated() {
            showAuthDialogAndSync()
            return false
        }
        
        return true
    }
    
    public func hasItemsToSync() -> Bool {
        if Storage.shared.itemsToSync().count < 1 {
            return false
        }
        return true
    }
    
    public func canSync(completion: @escaping (SyncValidation)->Void) {
        if !self.isEnabled { return completion(.SyncDisabled) }
        if Storage.shared.itemsToSync().count < 1 {
            return completion(.NothingToSync)
        }
        canReadFromApi(completion: completion)
    }
    
    public func canReadFromApi(completion: @escaping (SyncValidation)->Void) {
        if !isOnline() {
            return completion(.isOffline)
        }
        
        if !AuthenticationService.isAuthenticated() {
            return completion(.AuthExpired)
        }
        
        AccessService.shared.hasAccess(completion: { (hasAccess) in
            if !hasAccess {
                self.disableSync()
                return completion(.NeedsAccess)
            } else {
                return completion(.Ready)
            }
        })
    }
    
    func showAuthDialogAndSync() {
        if AuthenticationService.isAuthenticated() { return }
        Alert.show(title: "Authentication Required", message: "You need to authenticate to perform the initial sync.\n Would you like to authenticate now and synchronize?\n\nIf you select no, You will not be able to create records.\n", yes: {
            switch Settings.shared.getAuthType() {
            case .Idir:
                AuthenticationService.refreshEnviormentConstants(withIdpHint: "idir")
            case .BCeID:
                AuthenticationService.refreshEnviormentConstants(withIdpHint: "bceid")
            }
            AuthenticationService.authenticate(completion: { (success) in
                if success && Settings.shared.isCorrectUser() {
                    self.syncIfPossible()
                } else if !Settings.shared.isCorrectUser() {
                    AuthenticationService.logout()
                }
            })
        }) {
            self.disableSync()
        }
    }
    
    
    private func disableSync() {
        self.isEnabled = false
        self.endListener()
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
}
