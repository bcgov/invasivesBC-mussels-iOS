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

class Settings {
    
    static let shared = Settings()
    
    private init() {
        guard getModel() != nil else {
            let newModel = SettingsModel()
            RealmRequests.saveObject(object: newModel)
            return
        }
    }
    
    // MARK: Internal Functions
    private func getModel()-> SettingsModel? {
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
        guard let model = getModel() else {return false}
        return model.autoSyncEndbaled
    }
    
    func setAutoSync(enabled: Bool) {
        guard let model = getModel() else {return}
        AutoSync.shared.endListener()
        model.setAutoSync(enabled: enabled)
        if enabled {
            AutoSync.shared.beginListener()
            AutoSync.shared.sync()
            Banner.show(message: "AutoSync is on")
        } else {
            Banner.show(message: "AutoSync is off")
        }
    }
    
    // MARK: Users
    func setUser(firstName: String, lastName: String) {
        guard let model = getModel() else {return}
        model.setUser(firstName: firstName, lastName: lastName)
        //           NotificationCenter.default.post(name: .usernameUpdatedInSettings, object: nil)
    }
    
    func getUserName(full: Bool = false) -> String {
        guard let model = getModel() else {return ""}
        return full ? "\(model.userFirstName) \(model.userLastName)" : model.userFirstName
    }
    
    func getUserInitials() -> String {
        guard let model = getModel(), let last = model.userLastName.first, let first = model.userFirstName.first else {return "RO"}
        return ("\(first)\(last)")
    }
}
