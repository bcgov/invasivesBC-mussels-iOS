//
//  BaseRealmObject.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-28.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation

protocol BaseRealmObject {
    var localId: String { get set }
    var remoteId: Int { get set }
    
    
    var syncable: Bool { get set}
    var shouldSync: Bool { get set}

    func toDictionary() -> [String: Any]
    
    /*
     @objc dynamic var localId: String = {
        return UUID().uuidString
    }()

    override class func primaryKey() -> String? {
        return "localId"
    }
    @objc dynamic var remoteId: Int = -1
    */
}

