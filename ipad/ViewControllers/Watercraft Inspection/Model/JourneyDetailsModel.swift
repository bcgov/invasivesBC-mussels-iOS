//
//  JourneyDetailsModel.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-05.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation

import Realm
import RealmSwift

class JourneyDetailsModel: Object, BaseRealmObject {
    @objc dynamic var userId: String = ""
    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()
    
    override class func primaryKey() -> String? {
        return "localId"
    }
    
    var remoteId: Int = -1
    
    var shouldSync: Bool = false
    
    var previousWaterBodies: [[InputItem]] = []
    var destinationWaterBodies: [[InputItem]] = []
    
    func toDictionary() -> [String : Any] {
        return [String : Any]()
    }
}
