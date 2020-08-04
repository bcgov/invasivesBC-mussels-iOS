//
//  Settings.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-15.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Reachability

enum AuthType {
    case Idir
    case BCeID
}

class Settings {
    
    static let shared = Settings()
    
    private init() {
        guard Settings.getModel() != nil else {
            RealmRequests.getObject(SettingsModel.self)
            let newModel = SettingsModel()
            RealmRequests.saveObject(object: newModel)
            return
        }
    }
    
    // MARK: Internal Functions
    private static func getModel()-> SettingsModel? {
        if let query = RealmRequests.getObject(SettingsModel.self), let model = query.last {
            return model
        } else {
            return nil
        }
    }
    
    // MARK: App Version
    func getCurrentAppVersion() -> String {
        guard let infoDict = Bundle.main.infoDictionary, let version = infoDict["CFBundleShortVersionString"], let build = infoDict["CFBundleVersion"] else {return ""}
        return ("Version \(version) (\(build))")
    }
    
    // MARK: Sync
    func isAutoSyncEnabled()-> Bool {
        guard let model = Settings.getModel() else {return false}
        return model.autoSyncEndbaled
    }
    
    func setAutoSync(enabled: Bool) {
        guard let model = Settings.getModel() else {return}
        SyncService.shared.endListener()
        model.setAutoSync(enabled: enabled)
        if enabled {
            SyncService.shared.beginListener()
            SyncService.shared.syncIfPossible()
            Banner.show(message: "AutoSync is on")
        } else {
            Banner.show(message: "AutoSync is off")
        }
    }
    
    // MARK: Auth
    func setAuth(type: AuthType) {
        guard let model = Settings.getModel() else {return}
        model.setLoginType(idir: type == .Idir)
    }
    
    func getAuthType() -> AuthType {
        guard let model = Settings.getModel() else {return .Idir}
        return model.isIdirLogin ? .Idir : .BCeID
    }
    
    func isCorrectUser() -> Bool {
        guard let storedId = getUserAuthId() else {
            setUserAuthId()
            return true
        }
        return AuthenticationService.getUserID() == storedId
    }
    
    public func getUserAuthId() -> String? {
        guard let model = Settings.getModel() else {return nil}
        return model.authId
    }
    
    public func setUserAuthId() {
        guard let model = Settings.getModel() else {return}
        model.setAuth(id: AuthenticationService.getUserID())
    }
    
    // MARK: Users
    func setUserHasAppAccess(hasAccess: Bool) {
        guard let model = Settings.getModel() else {return}
        model.setUserAccess(hasAccess: hasAccess)
    }
    func userHasAppAccess() -> Bool {
        guard let model = Settings.getModel() else {return false}
        return model.userHasAccess
    }
    func setUser(firstName: String, lastName: String) {
        guard let model = Settings.getModel() else {return}
        model.setUser(firstName: firstName, lastName: lastName)
        //           NotificationCenter.default.post(name: .usernameUpdatedInSettings, object: nil)
    }
    
    func getUserName(full: Bool = false) -> String {
        guard let model = Settings.getModel() else {return ""}
        return full ? "\(model.userFirstName) \(model.userLastName)" : model.userFirstName
    }
    
    func getUserInitials() -> String {
        guard let model = Settings.getModel(), let last = model.userLastName.first, let first = model.userFirstName.first else {return "RO"}
        return ("\(first)\(last)")
    }
}
