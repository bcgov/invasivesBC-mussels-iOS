//
//  KeycloakConstants.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-28.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
struct SSO {
    struct Dev {
        static let baseUrl = URL(string: "https://sso-dev.pathfinder.gov.bc.ca")!
    }
    struct Test {
        static let baseUrl = URL(string: "https://sso-test.pathfinder.gov.bc.ca")!
    }
    struct Prod {
        static let baseUrl = URL(string: "https://sso.pathfinder.gov.bc.ca")!
    }
    
    static var baseUrl: URL {
        return SSO.Dev.baseUrl
//        switch SettingsManager.shared.getCurrentEnvironment() {
//        case .Dev:
//            return SSO.Test.baseUrl
//        case .Prod:
//            return SSO.Prod.baseUrl
//        }
    }
    static let redirectUri = "ibc-ios://client"
    static let clientId = "lucy"
    static let realmName = "dfmlcg7z"
    static var idpHint = ""
}
