//
//  Storage.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-03.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Storage {
    public static let shared = Storage()
    private init() {}
    
    public func itemsToSync() -> [ShiftModel] {
        do {
            let realm = try Realm()
            let objs = realm.objects(ShiftModel.self).filter("shouldSync == %@ AND userId == %@", true, AuthenticationService.getUserID()).map { $0 }
            return Array(objs)
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
            return []
        }
    }
    
    // MARK: Shifts
    public func shifts() -> [ShiftModel] {
        do {
            let realm = try Realm()
            let objs = realm.objects(ShiftModel.self).filter("userId == %@ ", AuthenticationService.getUserID()).map { $0 }
            return Array(objs)
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
            return []
        }
    }
    
    public func save(shift: ShiftModel) {
        do {
            let realm = try Realm()
            try realm.write {
                shift.userId = AuthenticationService.getUserID()
                realm.add(shift)
            }
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
        }
    }
    
    public func shifts(by shortDate: String) -> [ShiftModel] {
        do {
            let realm = try Realm()
            let objs = realm.objects(ShiftModel.self).filter("userId == %@ AND formattedDate == %@", AuthenticationService.getUserID(), shortDate).map { $0 }
            return Array(objs)
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
            return []
        }
    }
    
    public func shift(withLocalId localId: String) -> ShiftModel? {
        guard let realm = try? Realm(), let object = realm.objects(ShiftModel.self).filter("localId = %@", localId).first else {
            return nil
        }
        return object
    }
    
    // MARK: Inspections
    public func inspection(withLocalId localId: String) -> WatercradftInspectionModel? {
        guard let realm = try? Realm(), let object = realm.objects(WatercradftInspectionModel.self).filter("localId = %@", localId).first else {
            return nil
        }
        return object
    }
    
    // MARK: Code Tables
    public func codeTable(type: CodeTableType) -> [String] {
        do {
            let realm = try Realm()
            let objs = realm.objects(CodeTableModel.self).filter("type ==  %@", "\(type)").map { $0 }
            let found = Array(objs)
            if let first = found.first {
                return Array(first.items)
            } else {
                return []
            }
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
            return []
        }
    }
    
    public func codeObjects(type: CodeTableType) -> [String] {
        do {
            let realm = try Realm()
            let objs = realm.objects(CodeTableModel.self).filter("type ==  %@", "\(type)").map { $0 }
            let found = Array(objs)
            if let first = found.first {
                return Array(first.codes.map { $0.des })
            } else {
                return []
            }
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
            return []
        }
    }
    
    public func provinces() -> [String] {
        do {
           let realm = try Realm()
           let objs = realm.objects(CodeTableModel.self).filter("type ==  %@", "countryProvince").map { $0 }
           let found = Array(objs)
           if let first = found.first {
               return Array(first.provinces.map { $0.des })
           } else {
               return []
           }
       } catch let error as NSError {
           print("** REALM ERROR")
           print(error)
           return []
       }
    }
    
    public func provincesCodes() -> [CountryProvince] {
        do {
            let realm = try Realm()
            let objs = realm.objects(CodeTableModel.self).filter("type ==  %@", "countryProvince").map { $0 }
            let found = Array(objs)
            if let first = found.first {
                return Array(first.provinces)
            } else {
                return []
            }
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
            return []
        }
    }
    
    public func codes(type: CodeTableType) -> [CodeObject] {
        do {
            let realm = try Realm()
            let objs = realm.objects(CodeTableModel.self).filter("type ==  %@", "\(type)").map { $0 }
            let found = Array(objs)
            if let first = found.first {
                return Array(first.codes)
            } else {
                return []
            }
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
            return []
        }
    }
    
    public func codeId(type: CodeTableType, name: String) -> Int? {
        let codeTable = codes(type: type)
        for item in codeTable where item.des == name {
            return item.remoteId
        }
        return nil
    }
    
    public func codeTables() -> [CodeTableModel] {
        do {
            let realm = try Realm()
            let objs = realm.objects(CodeTableModel.self)
            return Array(objs)
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
            return []
        }
    }
    
    public func deleteCodeTables() {
        let all = codeTables()
        for each in all {
            RealmRequests.deleteObject(each)
        }
    }
    
    // MARK: Water Body
    public func fullWaterBodyTables() -> [WaterBodyTableModel] {
        do {
            let realm = try Realm()
            let objs = realm.objects(WaterBodyTableModel.self)
            return Array(objs)
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
            return []
        }
    }
    
    public func getWaterBodyDropdowns() -> [DropdownModel] {
        let waterbodies = fullWaterBodyTables()
        var dropdowns: [DropdownModel] = []
        for waterBody in waterbodies {
            dropdowns.append(DropdownModel(display: "\(waterBody.name), \(waterBody.province), \(waterBody.country) (\(waterBody.closest))", key: "\(waterBody.water_body_id)"))
        }
        return dropdowns
    }
    
    public func getWaterbodyModel(withId id: Int) -> WaterBodyTableModel? {
        do {
            let realm = try Realm()
            let objs = realm.objects(WaterBodyTableModel.self).filter("water_body_id ==  %@", id).map { $0 }
            let found = Array(objs)
            return found.first
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
            return nil
        }
    }
    
    public func getWaterbodies(inProvince province: String) -> [String] {
        do {
            let realm = try Realm()
            let objs = realm.objects(WaterBodyTableModel.self).filter("abbrev ==  %@", province).map { $0 }
            let found = Array(objs)
            return found.map{ $0.name}
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
            return []
        }
    }
    
    public func getWaterbodies(nearCity city: String) -> [String] {
        do {
            let realm = try Realm()
            let objs = realm.objects(WaterBodyTableModel.self).filter("closest ==  %@", city).map { $0 }
            let found = Array(objs)
            return found.map{ $0.name}
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
            return []
        }
    }
    
    public func getCities(nearWaterBody waterBody: String) -> [String] {
        do {
            let realm = try Realm()
            let objs = realm.objects(WaterBodyTableModel.self).filter("name ==  %@", waterBody).map { $0 }
            let found = Array(objs)
            return found.map{ $0.closest}
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
            return []
        }
    }
    
    public func getCities(inProvince province: String) -> [String] {
        do {
            let realm = try Realm()
            let objs = realm.objects(WaterBodyTableModel.self).filter("abbrev ==  %@", province).map { $0 }
            let found = Array(objs)
            return found.map{ $0.closest}
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
            return []
        }
    }
    
    public func getProvinces(withWaterBody waterBody: String) -> [String] {
        do {
            let realm = try Realm()
            let objs = realm.objects(WaterBodyTableModel.self).filter("name ==  %@", waterBody).map { $0 }
            let found = Array(objs)
            return found.map{ $0.country}
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
            return []
        }
    }
    
    public func getProvinces(withCity city: String) -> [String] {
        do {
            let realm = try Realm()
            let objs = realm.objects(WaterBodyTableModel.self).filter("closest ==  %@", city).map { $0 }
            let found = Array(objs)
            return found.map{ $0.country}
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
            return []
        }
    }
    
    public func deteleFullWaterBodyTables() {
        let all = fullWaterBodyTables()
        for each in all {
            RealmRequests.deleteObject(each)
        }
    }
    
    // MARK: Water Bodies from JSON
    func saveWaterBodiesFromJSON(status: @escaping(_ newStatus: String) -> Void) {
        let filePath = Bundle.main.url(forResource: "waterBodies", withExtension: "txt")!
        do {
            let data = try Data(contentsOf: filePath, options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            
            if let jsonResult = jsonResult as? [[String: Any]] {
                Storage.shared.deteleFullWaterBodyTables()
                var counter = 1
                for item in jsonResult {
                    status("Storing Waterbodies:\t\((counter * 100 ) / jsonResult.count)%")
                    counter += 1
                    let model = WaterBodyTableModel()
                    model.name = item["Name"] as? String ?? ""
                    model.water_body_id = item["water_body_id"] as? Int ?? 0
                    model.latitude = item["LatDD"] as? Double ?? 0
                    model.longitude = item["LongDD"] as? Double ?? 0
                    model.country = item["Abbrev"] as? String ?? ""
                    model.closest = item["Closest"] as? String ?? ""
                    if model.name == "" || model.country == "" || model.closest == "" {
                        continue
                    } else {
                        RealmRequests.saveObject(object: model)
                    }
                }
            } else {
                print("Cant read")
            }
        } catch {
            // handle error
            print("Error")
        }
    }
}
