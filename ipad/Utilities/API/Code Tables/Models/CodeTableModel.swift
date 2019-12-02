//
//  CodeTableModel.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-26.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation

import Realm
import RealmSwift


class CodeTableModel: Object {
    
    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()
    
    override class func primaryKey() -> String? {
        return "localId"
    }
    
    @objc dynamic var type: String = ""
    let items: List<String> = List<String>()
}

class WaterBodyTableModel: Object {
    
    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()
    
    override class func primaryKey() -> String? {
        return "localId"
    }
    
    @objc dynamic var name: String = ""
    @objc dynamic var water_body_id: Int = 0
    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0
    @objc dynamic var abbrev: String = ""
    @objc dynamic var closest: String = ""
    
    func toDictionary() -> [String : Any] {
        return [
            "name": name,
            "water_body_id": water_body_id,
            "latitude": latitude,
            "longitude": longitude,
            "abbrev": abbrev,
            "closest": closest
        ]
    }
}
