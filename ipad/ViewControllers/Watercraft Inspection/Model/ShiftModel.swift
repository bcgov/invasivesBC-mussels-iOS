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
    
    @objc dynamic var startTime: TimeInterval = 0
    @objc dynamic var endTime: TimeInterval = 0
    @objc dynamic var boatsInspected: Bool = false
    @objc dynamic var motorizedBlowBys: Int = 0
    @objc dynamic var nonMotorizedBlowBys: Int = 0
    @objc dynamic var k9OnShif: Bool = false
    
    @objc dynamic var sunny: Bool = false
    @objc dynamic var cloudy: Bool = false
    @objc dynamic var raining: Bool = false
    @objc dynamic var snowing: Bool = false
    @objc dynamic var foggy: Bool = false
    @objc dynamic var windy: Bool = false
    
    @objc dynamic var date: Date?
    ///
    @objc dynamic var station: String = ""
    @objc dynamic var location: String = ""
    ///
    @objc dynamic var shitStartComments: String = ""
    @objc dynamic var shitEndComments: String = ""
    
    var inspections: List<WatercradftInspectionModel> = List<WatercradftInspectionModel>()
    
    // TODO:
    var status: String {
        return "synced"
    }
    
    func toDictionary() -> [String : Any] {
        return [String : Any]()
    }
    
    
    // MARK: UI Helpers
    func getShiftStartFields(forModal: Bool, editable: Bool) -> [InputItem] {
        return ShiftFormHelper.getShiftStartFields(for: self, editable: editable, modalSize: forModal)
    }
    
    func getShiftEndFields(editable: Bool) -> [InputItem] {
        return ShiftFormHelper.getShiftEndFields(for: self, editable: editable)
    }
}
