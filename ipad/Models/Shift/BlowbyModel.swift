//
//  BlowbyModel.swift
//  ipad
//
//  Created by Matthew Logan on 2024-01-02.
//  Copyright © 2024 Amir Shayegh. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class BlowbyModel: Object, BaseRealmObject {
  @objc dynamic var userId: String = "";
  @objc dynamic var localId: String = {
    return UUID().uuidString
  }()
  @objc dynamic func primaryKey() -> String? {
    return "localId"
  }
  @objc dynamic var timeStamp: Date = Date()
  @objc dynamic var remoteId: Int = -1;
  @objc dynamic var shouldSync: Bool = false
  
  @objc dynamic var reportedToRapp: Bool = false;
  @objc dynamic var blowByTime: String = "";
  @objc dynamic var watercraftComplexity: String = ""
  
  func set(value: Any, for key: String) {
    if self[key] == nil {
      print("\(key) is nil");
      return
    }
    do {
      let realm = try Realm()
      try realm.write {
        self[key] = value
      }
    } catch let error as NSError {
      print("** REALM ERROR");
      print(error);
    }
  }
  func toDictionary() -> [String : Any] {
     return [
      "blowByTime": blowByTime,
      "watercraftComplexity": watercraftComplexity,
      "reportedToRapp": reportedToRapp
    ]
  }
  
}
