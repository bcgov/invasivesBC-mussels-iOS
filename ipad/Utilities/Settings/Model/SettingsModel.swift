//
//  SettingsModel.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-15.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Reachability

class SettingsModelCache {
    var autoSyncEndbaled: Bool = true
    var userFirstName: String = ""
    var userLastName: String = ""
    var isIdirLogin: Bool = true
    
    init(from model: SettingsModel) {
        self.autoSyncEndbaled = model.autoSyncEndbaled
        self.userFirstName = model.userFirstName
        self.userLastName = model.userLastName
    }
}

class SettingsModel: Object {
    
    @objc dynamic var realmID: String = {
        return UUID().uuidString
    }()
    
    override class func primaryKey() -> String? {
        return "realmID"
    }
    
    @objc dynamic var autoSyncEndbaled: Bool = true
    @objc dynamic var userHasAccess: Bool = false
    
    // UX
    @objc dynamic var userFirstName: String = ""
    @objc dynamic var userLastName: String = ""
    @objc dynamic var isIdirLogin: Bool = true
    @objc dynamic var authId: String = ""
    
    func clone() -> SettingsModel {
        let new = SettingsModel()
        new.autoSyncEndbaled = self.autoSyncEndbaled
        // dont clone user name
        return new
    }
    
    func setFrom(cache: SettingsModelCache) {
        self.autoSyncEndbaled = cache.autoSyncEndbaled
        self.userFirstName = cache.userFirstName
        self.userLastName = cache.userLastName
    }
    
    // MARK: Setters
    func setAutoSync(enabled: Bool) {
        do {
            let realm = try Realm()
            try realm.write {
                autoSyncEndbaled = enabled
            }
        } catch _ {
        }
    }
    
    func setUser(firstName: String, lastName: String) {
        do {
            let realm = try Realm()
            try realm.write {
                userFirstName = firstName
                userLastName = lastName
            }
        } catch _ {
        }
    }
    
    func setLoginType(idir: Bool) {
        do {
            let realm = try Realm()
            try realm.write {
                isIdirLogin = idir
            }
        } catch _ {
        }
    }
    
    func setAuth(id: String) {
        do {
            let realm = try Realm()
            try realm.write {
                authId = id
            }
        } catch _ {
        }
    }
    
    func setUserAccess(hasAccess: Bool) {
        do {
            let realm = try Realm()
            try realm.write {
                userHasAccess = hasAccess
            }
        } catch _ {
        }
    }
}
