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
            let objs = realm.objects(ShiftModel.self).filter("shouldSync == %@ AND userId == %@", true, Auth.getUserID()).map { $0 }
            return Array(objs)
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
            return []
        }
    }
    
    public func shifts() -> [ShiftModel] {
        do {
            let realm = try Realm()
            let objs = realm.objects(ShiftModel.self).filter("userId == %@ ", Auth.getUserID()).map { $0 }
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
                shift.userId = Auth.getUserID()
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
            let objs = realm.objects(ShiftModel.self).filter("userId == %@ AND formattedDate == %@", Auth.getUserID(), shortDate).map { $0 }
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
    
    public func inspection(withLocalId localId: String) -> WatercradftInspectionModel? {
        guard let realm = try? Realm(), let object = realm.objects(WatercradftInspectionModel.self).filter("localId = %@", localId).first else {
            return nil
        }
        return object
    }
    
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
    
    public func waterBodyTables() -> [WaterBodyTableModel] {
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
    
    public func deteleWaterBodyTables() {
        let all = waterBodyTables()
        for each in all {
            RealmRequests.deleteObject(each)
        }
    }
    
    public func storeWaterBodyTableFromJSONIfNeeded() {
        guard self.waterBodyTables().count < 1 else {
            return
        }
        
    }
    
    public func saveWaterBodiesToJSON() {
        saveToJSONFile()
        getJSONFile()
    }
    
    private func saveToJSONFile() {
        // Get the url of Persons.json in document directory
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileUrl = documentDirectoryUrl.appendingPathComponent("waterBodies.txt")
        
        let objects = waterBodyTables()
        let dictionaries: [[String: Any]] = objects.map{ $0.toDictionary()}
        
        // Transform array into data and save it into file
        do {
            let data = try JSONSerialization.data(withJSONObject: dictionaries, options: [])
            try data.write(to: fileUrl, options: [])
            print("Successfully created file\n** Use po NSHomeDirectory() to find out where.")
        } catch {
            print(error)
        }
    }
    
    func saveWaterBodiesFromJSON(status: @escaping(_ newStatus: String) -> Void) {
        let filePath = Bundle.main.url(forResource: "waterBodies", withExtension: "txt")!
        do {
            let data = try Data(contentsOf: filePath, options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            
            if let jsonResult = jsonResult as? [[String: Any]] {
                print(jsonResult.count)
                print("Read")
                Storage.shared.deteleWaterBodyTables()
                var counter = 1
                for item in jsonResult {
                    status("\((counter * 100 ) / jsonResult.count)%")
//                    status("\(counter) of \(jsonResult.count)")
                    let model = WaterBodyTableModel()
                    model.name = item["name"] as? String ?? ""
                    model.water_body_id = item["water_body_id"] as? Int ?? 0
                    model.latitude = item["latitude"] as? Double ?? 0
                    model.longitude = item["longitude"] as? Double ?? 0
                    model.abbrev = item["abbrev"] as? String ?? ""
                    model.closest = item["closest"] as? String ?? ""
                    RealmRequests.saveObject(object: model)
                    counter += 1
                }
            } else {
                print("Cant read")
            }
        } catch {
            // handle error
            print("Error")
        }
    }
    
    private func getJSONFile() {
        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileUrl = documentDirectoryUrl.appendingPathComponent("waterBodies.txt")
        do {
            let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
            
            if let jsonResult = jsonResult as? [[String: Any]] {
                print("Read")
            } else {
                print("Cant read")
            }
        } catch {
            // handle error
            print("Error")
        }
    }
}
