import Foundation
import Realm
import RealmSwift


class MajorCityModel: JourneyModel, BaseRealmObject {
    @objc dynamic var userId: String = ""
    
    override class func primaryKey() -> String? {
        return "localId"
    }
    
    @objc dynamic var majorCity: String = ""
    @objc dynamic var nearestWaterBody: String = ""
    @objc dynamic var province: String = ""
    @objc dynamic var otherWaterbody: String = ""
    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0
    @objc dynamic var country: String = ""
    
    func set(from model: MajorCitiesTableModel) {
        do {
            let realm = try Realm()
            try realm.write {
                self.majorCity = model.city_name
                self.nearestWaterBody = model.closest_water_body
                self.province = model.province
                self.remoteId = model.major_city_id
                self.latitude  = model.city_latitude
                self.longitude = model.city_longitude
                self.country = model.country_code
                self.numberOfDaysOut = ""
            }
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
        }
    }
    
    func setNumberOfDaysOut(_ value: String) {
        do {
            let realm = try Realm()
            try realm.write {
                self.numberOfDaysOut = value
            }
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
        }
    }
    
    func set(value: Any, for key: String) {
        if self[key] == nil {
            print("\(key) is nil")
            return
        }
        do {
            let realm = try Realm()
            try realm.write {
                if key == "numberOfDaysOut" {
                    self.numberOfDaysOut = value as? String ?? "N/A"
                } else {
                    self[key] = value
                }
            }
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
        }
    }
    
    override subscript(key: String) -> Any? {
        get {
            switch key {
            case "majorCity":
                return self.majorCity
            case "province":
                return self.province
            case "country":
                return self.country
            case "numberOfDaysOut":
                return self.numberOfDaysOut
            default:
                return super[key]
            }
        }
        set {
            switch key {
            case "majorCity":
                if let value = newValue as? String {
                    self.majorCity = value
                }
            case "province":
                if let value = newValue as? String {
                    self.province = value
                }
            case "country":
                if let value = newValue as? String {
                    self.country = value
                }
            case "numberOfDaysOut":
                if let value = newValue as? String {
                    self.numberOfDaysOut = value
                }
            default:
                super[key] = newValue
            }
        }
    }
    
    func toDictionary() -> [String : Any] {
        if self.remoteId < 0 {
            return [:]
        }
        
        return [
            "name": majorCity,
            "nearestWaterBody": nearestWaterBody,
            "province": province,
            "country": country,
            "numberOfDaysOut": numberOfDaysOut.count > 0 ? numberOfDaysOut : "N/A"
        ]
    }
}
