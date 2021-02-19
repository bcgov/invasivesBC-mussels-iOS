//
//  MajorCitiesTableModel.swift
//  ipad
//
//  Created by Warren, Sam on 2021-02-08.
//  Copyright © 2021 Amir Shayegh. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class MajorCitiesTableModel: Object {
    
    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()
    
    override class func primaryKey() -> String? {
        return "localId"
    }
    
    @objc dynamic var city_name: String = ""
    @objc dynamic var city_latitude: Double = 0
    @objc dynamic var city_longitude: Double = 0
    @objc dynamic var country_code: String = ""
    @objc dynamic var closest_water_body: String = ""
    @objc dynamic var province: String = ""
    @objc dynamic var distance: Double = 0
    
    func toDictionary() -> [String : Any] {
        return [
            "city_name": city_name,
            "city_latitude": city_latitude,
            "city_longitude": city_longitude,
            "country_code": country_code,
            "closest_water_body": closest_water_body,
            "province": province,
            "distance": distance,
        ]
    }
}
