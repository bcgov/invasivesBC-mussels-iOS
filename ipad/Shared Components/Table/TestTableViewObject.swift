//
//  TableViewTestModel.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-20.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class TestTableViewObject: Object, BaseRealmObject {
    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()
    
    override class func primaryKey() -> String? {
        return "localId"
    }
    
    @objc dynamic var remoteId: Int = -1
    @objc dynamic var shouldSync: Bool = false
    
    @objc dynamic var riskLevel: String = ""
    @objc dynamic var timeAdded: String = ""
    @objc dynamic var status: String = ""
    
    func toDictionary() -> [String : Any] {
        return [String : Any]()
    }
    
    
}
