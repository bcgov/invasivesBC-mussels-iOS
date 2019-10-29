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

enum SyncedItem {
    case Drafts
    case Statuses
    case Outbox
}
//
//extension UIView {
//
////    public static func viewController<T:UIViewController>(type: T.Type? = nil) -> T? {
////        if Thread.isMainThread {
////            return viewController(ofType: type)
////        } else {
////            var found: T?
////            DispatchQueue.main.sync {
////                found = viewController(ofType: type)
////            }
////            return found
////        }
////    }
//
//    public static func viewController<T: UIViewController>(ofType: T.Type? = nil) -> T? {
//        func find() -> T? {
//            guard let appDelegate: AppDelegate = UIApplication.shared.delegate as? AppDelegate else {return nil}
//            if let vc = appDelegate.window?.rootViewController as? T {
//                return vc
//            }else if let vc = appDelegate.window?.rootViewController?.presentedViewController as? T {
//                return vc
//            }else if let vc = appDelegate.window?.rootViewController?.children {
//                return vc.lazy.compactMap {$0 as? T}.first
//            }
//            return nil
//        }
//
//        if Thread.isMainThread {
//            return find()
//        } else {
//            var found: T?
//            DispatchQueue.main.sync {
//                found = find()
//            }
//            return found
//        }
//    }
//}
/*
class AutoSync {
    
    internal static let shared = AutoSync()
    
    var realmNotificationToken: NotificationToken?
    var isSynchronizing: Bool = false
    var manualSyncRequiredShown = false
    
    private init() {}
    
    // MARK: AutoSync Listener
    func beginListener() {
        
        print("Listening to database changes in AutoSync.")
        do {
            let realm = try Realm()
            self.realmNotificationToken = realm.observe { notification, realm in
                print("Change observed in AutoSync...")
                
                if let r = try! Reachability(), r.connection == .none {
                    print(message: "But you're offline.")
                    return
                }
                self.autoSynchronizeIfPossible()
            }
        } catch _ {
            Logger.fatalError(message: LogMessages.databseChangeListenerFailure)
        }
    }
    
    func autoSynchronizeIfPossible() {
        print("Checking if we can autosync...")
        if self.isSynchronizing {
            print("You're already synchronizing.")
            return
        }
        
        if aPlanIsBeingEdited() {
            Logger.log(message: "A Plan is being edited.")
            return
        }
        
        // Put a 1 second delay to account for presentation of screens:
        // We want to make sure aytosync is never run when a plan is being edited
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // if still not editing..
            if !self.aPlanIsBeingEdited() {
                self.autoSync()
            } else {
                Logger.log(message: "A Plan is being edited.")
            }
        }
    }
    
    func endListener() {
        if let token = self.realmNotificationToken {
            token.invalidate()
            Logger.log(message: "Stopped listening to database changes in AutoSync.")
        }
    }
    
    // MARK: AutoSync Action
    func autoSync() {
        if !shouldAutoSync() {
            return
        }
        
        Logger.log(message: "Executing Autosync...")
        
        // set some variables
        self.manualSyncRequiredShown = false
        self.isSynchronizing = true
        
        // Add the autosync view
        let autoSyncView: AutoSyncView = UIView.fromNib()
        autoSyncView.initialize()
        // Lets move to a background thread
        DispatchQueue.global(qos: .background).async {
            
            var syncedItems: [SyncedItem] = [SyncedItem]()
            
            let dispatchGroup = DispatchGroup()
            
            // Outbox
            if self.shouldUploadOutbox() {
                dispatchGroup.enter()
                let outboxPlans = RUPManager.shared.getOutboxRups()
                API.upload(plans: outboxPlans, completion: { (success) in
                    if success {
                        Logger.log(message: "Uploaded outbox plans")
                        syncedItems.append(.Outbox)
                        dispatchGroup.leave()
                    } else {
                        dispatchGroup.leave()
                    }
                })
            }
            
            // Statuses
            if self.shouldUpdateRemoteStatuses() {
                dispatchGroup.enter()
                let updatedPlans = RUPManager.shared.getRUPsWithUpdatedLocalStatus()
                API.upload(statusesFor: updatedPlans, completion: { (success) in
                    if success {
                        Logger.log(message: "Uplodated statuses")
                        syncedItems.append(.Statuses)
                        dispatchGroup.leave()
                    } else {
                        dispatchGroup.leave()
                    }
                })
            }
            
            // Drafts
            if self.shouldUploadDrafts() {
                dispatchGroup.enter()
                let draftPlans = RUPManager.shared.getDraftRupsValidForUpload()
                API.upload(plans: draftPlans, completion: { (success) in
                    if success {
                        Logger.log(message: "Uploaded drafts")
                        syncedItems.append(.Drafts)
                        dispatchGroup.leave()
                    } else {
                        dispatchGroup.leave()
                    }
                })
            }
            
            // End
            dispatchGroup.notify(queue: .main) {
                Logger.log(message: "Autosync Executed.")
                
                // if home page is presented, reload its content
                if let home = UIView.viewController(ofType: HomeViewController.self) {
                    Logger.log(message: "Reloading plans in home page after autosync")
                    home.LoadPlans()
                }
//                if let home = self.getPresentedHome() {
//                    Logger.log(message: "Reloading plans in home page after autosync")
//                    home.loadRUPs()
//                }
                
                // Display a banner.
                Banner.shared.show(message: self.generateSyncMessage(elements: syncedItems))
                
                // remove the view
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    autoSyncView.remove()
                    // free autosync
                    self.isSynchronizing = false
                }
            }
        }
    }
    
    // MARK: Criteria
    func shouldAutoSync() -> Bool {
        Logger.log(message: "Checking if Autosync should be executed...")
        
        if aPlanIsBeingEdited() {
            Logger.log(message: "No. A plan is being viewed or edited.")
            return false
        }
        
        guard let r = Reachability() else {
            Logger.log(message: "No. Can't check connectivity offline.")
            return false
        }
        
        if !SettingsManager.shared.isAutoSyncEnabled() {
            Logger.log(message: "No. Autosync is blocked.")
            return false
        }
        
        if r.connection == .none {
            Logger.log(message: "No. You're offline.")
            return false
        }
        
        if self.isSynchronizing {
            Logger.log(message: "No. A sync is in progress.")
            return false
        }
        
        if !self.shouldUploadOutbox() && !self.shouldUpdateRemoteStatuses() && !self.shouldUploadDrafts() {
            Logger.log(message: "No. Nothing to sync")
            return false
        }
        
        if !Auth.isAuthenticated() {
            Logger.log(message: "No. You're not authenticated.")
            Logger.log(message: "Showung options")
            if !manualSyncRequiredShown {
                manualSyncRequiredShown = true
                Alert.show(title: "Authentication Required", message: "You have plans that need to be synced.\n Would you like to authenticate now and synchronize?\n\nIf you select no, Autosync will be turned off.\nAutosync can be turned on and off in the settings page.", yes: {
                    Auth.authenticate(completion: { (success) in
                        if success {
                            self.autoSync()
                        }
                    })
                }) {
                    SettingsManager.shared.setAutoSync(enabled: false)
                    Banner.shared.show(message: Messages.AutoSync.manualSyncRequired)
                }
            }
            return false
        }
        
        return true
    }
    
    func aPlanIsBeingEdited() -> Bool {
        if  UIView.viewController(ofType: CreateNewRUPViewController.self) != nil ||
            UIView.viewController(ofType: PlantCommunityViewController.self) != nil ||
            UIView.viewController(ofType: ScheduleViewController.self) != nil {
            Logger.log(message: "No. A plan is being viewed or edited.")
            return true
        }
        return false
    }
    
    func shouldUploadOutbox() -> Bool {
        return (RUPManager.shared.getOutboxRups().count > 0)
    }
    
    func shouldUpdateRemoteStatuses() -> Bool {
        return (RUPManager.shared.getRUPsWithUpdatedLocalStatus().count > 0)
    }
    
    // MARK: Messages
    func generateSyncMessage(elements: [SyncedItem]) -> String {
        var body: String = ""
        for element in elements {
            let new = "\(body)\(element)"
            body = "\(new), "
        }
        
        // clean it up
        body = body.replacingLastOccurrenceOfString(",", with: "")
        body = body.replacingLastOccurrenceOfString(" ", with: ".")
        
        // if we only had 2 elements, replace the comma with and
        body = body.replacingLastOccurrenceOfString(",", with: " and")
        
        if body.isEmpty {
            return ""
        } else {
            return "AutoSynced \(body)"
        }
    }
    
    func shouldUploadDrafts() -> Bool {
        // Should not upload drafts if we're in create page: might be editing the draft
        if self.aPlanIsBeingEdited() {
            Logger.log(message: "Should not upload drafts when from page is presented.")
            return false
        } else {
            let drafts = RUPManager.shared.getDraftRups()
            for draft in drafts {
                if draft.canBeUploadedAsDraft() {
                    return true
                }
            }
            return false
        }
    }
}
*/
