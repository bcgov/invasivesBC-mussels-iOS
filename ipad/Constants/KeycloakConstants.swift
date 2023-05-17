//
//  KeycloakConstants.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-28.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
struct SSO {
    static var baseUrl: URL {
        return RemoteURLManager.default.keyCloakURL
    }
    
    static let redirectUri = "ibc-ios://client"
    static let clientId = "inspect-bc-mussels-4817"
    static let realmName = "standard"
    static var idpHint = ""
}
