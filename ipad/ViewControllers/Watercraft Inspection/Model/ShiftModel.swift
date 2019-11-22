//
//  ShiftModel.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-21.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

extension ShiftModel: PropertyReflectable {}

class ShiftModel: Object, BaseRealmObject {
    
   @objc dynamic var localId: String = {
        return UUID().uuidString
    }()
    
    override class func primaryKey() -> String? {
        return "localId"
    }
    
    @objc dynamic var remoteId: Int = -1
    @objc dynamic var shouldSync: Bool = false
    
    @objc dynamic var date: Date?
    @objc dynamic var location: String = ""
    var inspections: List<WatercradftInspectionModel> = List<WatercradftInspectionModel>()
    
    
    // TODO:
    var status: String {
        return "synced"
    }
    
    func toDictionary() -> [String : Any] {
        return [String : Any]()
    }
    
}
