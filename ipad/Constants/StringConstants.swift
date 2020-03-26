//
//  StringConstants.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-28.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation

enum AlertMessage {
    case Logout
    case IsOffline
    case NeedsAccess
    case NothingToSync
    case SyncIsDisabled
    case LoginExpired
}

struct StringConstants {
    static let appTitle: String = "InvasivesBC"
    struct Alerts {
        struct Logout {
            static let title: String = "Would you like to logout?"
            static let message: String = ""
        }
        
        struct IsOffline {
            static let title: String = "Can't Synchronize"
            static let message: String = "Device is offline"
        }
        
        struct NeedsAccess {
            static let title: String = "Access Deined"
            static let message: String = "You need the required access level to submit.\nAccess request has been created and is awaiting approval"
        }
        
        struct NothingToSync {
            static let title: String = "Nothing to sync"
            static let message: String = "There is nothing to sync"
        }
        
        struct SyncIsDisabled {
            static let title: String = "Sync is disabled"
            static let message: String = "Please re-start application"
        }
        
        struct LoginExpired {
            static let title: String = "Authentication Required"
            static let message: String = "You need to authenticate to perform the initial sync.\n Would you like to authenticate now and synchronize?\n\nIf you select no, You will not be able to create records.\n"
        }
    }
    
    struct EmptyTable {
        static let title: String = ""
        static let shifts: String = ""
        static let inspections: String = ""
    }
}
