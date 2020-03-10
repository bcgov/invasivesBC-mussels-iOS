//
//  CodeTables.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-26.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Reachability
import Alamofire
import SwiftyJSON

public enum CodeTableType {
    case observers
    case otherObservations
    case stations
    case watercraftList
    case waterBodies
    case cities
    case provinces
    case adultMusselsLocation
    case previousAISKnowledgeSource
    case previousInspectionSource
}

class CodeTables {
    
    static let shared = CodeTables()
    private init() {}
    
    private let waterBodyAPI: WaterBodyAPI =  WaterBodyAPI.api()
    private let codesAPI: CodesAPI = CodesAPI.api()
    
    var promise: Promise<RemoteResponse>?
    
    deinit {
        InfoLog("De-init")
    }
    
    public func fetchCodes(completion: @escaping(_ success: Bool) -> Void, status: @escaping(_ newStatus: String) -> Void) {
        status("Fetching...")
        let group = DispatchGroup()
        var hadFails = false
        group.enter()
        self.fetchAndStoreCodeTables(completion: { (codeTablesFetched) in
            if !codeTablesFetched {
                hadFails = true
            }
            group.leave()
        }, status: status)
        
        group.enter()
        self.fetchAndStoreWaterBodies(completion: { (waterBodiesFetched) in
            if !waterBodiesFetched {
                hadFails = true
            }
            status("Wrapping up")
            let waterBodies = Storage.shared.fullWaterBodyTables()
            let provinces = waterBodies.map{$0.province}.uniques.sorted{$0.lowercased() < $1.lowercased()}
            let cities = waterBodies.map{$0.closest}.uniques.sorted{$0.lowercased() < $1.lowercased()}
            let waters = waterBodies.map{$0.name}.uniques.sorted{$0.lowercased() < $1.lowercased()}
            
            let provincesTable = CodeTableModel()
            provincesTable.type = "provinces"
            for province in provinces {
                provincesTable.items.append(province)
            }
            RealmRequests.saveObject(object: provincesTable)
            
            let citiesTable = CodeTableModel()
            citiesTable.type = "cities"
            for city in cities {
                citiesTable.items.append(city)
            }
            RealmRequests.saveObject(object: citiesTable)
            
            let watersTable = CodeTableModel()
            watersTable.type = "waterBodies"
            for city in waters {
                watersTable.items.append(city)
            }
            RealmRequests.saveObject(object: watersTable)
            
            group.leave()
        }, status: status)
        
        group.notify(queue: .main) {
            return completion(!hadFails)
        }
    }
    
    public func fetchAndStoreCodeTables(completion: @escaping (_ success: Bool) -> Void, status: @escaping(_ newStatus: String) -> Void) {
        status("Fetching Code Tables")
        APIRequest.fetchCodeTables { (response) in
            // Check for failure
            guard let result = response else {
                return completion(false)
            }
            status("Removing Existing Code Tables")
            Storage.shared.deleteCodeTables()
            status("Processing Code Tables")
            let codeTables = self.processCodeTableJSON(dict: result)
            status("Storing Code Tables")
            DispatchQueue.global(qos: .background).async {
                let group = DispatchGroup()
                for codeTable in codeTables {
                    group.enter()
                    RealmRequests.saveObject(object: codeTable)
                    group.leave()
                }
                group.notify(queue: .main) {
                    return completion(true)
                }
            }
        }
    }
    
    private func processCodeTableJSON(dict: [String: Any]) -> [CodeTableModel]{
        var codeTables: [CodeTableModel] = []
        
        for (key, value) in dict {
            guard let itemJSON: [JSON] = value as? [JSON] else {
                ErrorLog("Unexpected code array received")
                continue
            }
            let tempCodeItems = itemJSON.map { $0.dictionaryObject }
            if let codeItems: [[String: Any]] = tempCodeItems as? [[String: Any]] {
                // Saving CodeObj
                let model = CodeTableModel()
                model.type = key
                let _: [CodeObject] = codeItems.map({ (codeDict: [String : Any]) -> CodeObject in
                    let codeObj = CodeObject()
                    // Get id key
                    let idKey: [String] = codeDict.keys.filter { (k: String) -> Bool in
                        return k.contains("_id")
                    }
                    let id = idKey[0]
                    codeObj.des = codeDict["description"] as? String ?? "NA"
                    codeObj.remoteId = codeDict[id] as? Int ?? -1
                    model.codes.append(codeObj)
                    return codeObj
                })
                codeTables.append(model)
                continue
            }
            let items = itemJSON.map { $0.stringValue }
            let model = CodeTableModel()
            model.type = key
            for item in items {
                model.items.append(item)
            }
            codeTables.append(model)
        }
        return codeTables
    }
    
    private func fetchAndStoreWaterBodies(completion: @escaping (_ success: Bool) -> Void, status: @escaping(_ newStatus: String) -> Void) {
        status("Fetching Waterbodies")
        APIRequest.fetchWaterBodies { (response) in
            guard let result = response else {
                return completion(false)
            }
            status("Removing Old Data")
            Storage.shared.deteleFullWaterBodyTables()
            status("Processing Waterbodies")
            let waterbodies = self.processWaterBodiesJSON(dict: result)
            DispatchQueue.global(qos: .background).async {
                var counter = 1
                let group = DispatchGroup()
                
                for waterbody in waterbodies {
                    group.enter()
                    status("Storing Waterbodies\n \((counter * 100 ) / waterbodies.count)%")
                    RealmRequests.saveObject(object: waterbody)
                    counter += 1
                    group.leave()
                }
                
                group.notify(queue: .main) {
                    return completion(true)
                }
            }
        }
    }
    
    private func processWaterBodiesJSON(dict: [[String: Any]]) -> [WaterBodyTableModel]{
        var waterbodies: [WaterBodyTableModel] = []
        for item in dict {
            let model = WaterBodyTableModel()
            model.name = (item["name"] as? JSON)?.string ?? ""
            model.water_body_id = (item["water_body_id"] as? JSON)?.int ?? 0
            model.latitude = (item["latitude"] as? JSON)?.double ?? 0
            model.longitude = (item["longitude"] as? JSON)?.double ?? 0
            model.country = (item["country"] as? JSON)?.string ?? ""
            model.closest = (item["closest"] as? JSON)?.string ?? ""
            model.province = (item["province"] as? JSON)?.string ?? ""
            if model.water_body_id > 0 {
                waterbodies.append(model)
            }
        }
        return waterbodies
    }
    
    
    func findWaterbody(name: String, province: String, nearestCity: String) -> WaterBodyTableModel? {
        let allWaterbodies = Storage.shared.fullWaterBodyTables()
        for element in allWaterbodies where element.name == name && element.country == province && element.closest == nearestCity {
            return element
        }
        return nil
    }
}

// MARK: Fetching using Promise
extension CodeTables {
    private func OLD_fetchAndStoreCodes(completion: @escaping (_ success: Bool) -> Void, status: @escaping(_ newStatus: String) -> Void) {
        do {
            let reacahbility = try Reachability()
            if (reacahbility.connection == .unavailable) {
                return completion(false)
            }
        } catch let error as NSError {
            print("** Reachability ERROR")
            print(error)
        }
        status("Fetching Code Tables")
        self.promise = codesAPI.get()
        
        self.promise?.then({ (resp, _) in
            status("Storing Code Tables")
            guard let data: [String: Any] = resp as? [String: Any] else {
                print("FAIL: Wrong resp")
                status("Could not fetch Code Tables")
                return completion(false)
            }
            Storage.shared.deleteCodeTables()
            DispatchQueue.global(qos: .background).async {
                var codeTables: [CodeTableModel] = []
                var counter = 0
                for (type, items) in data {
                    guard let items = items as? [String] else {
                        continue
                    }
                    status("Storing Code Tables:\t\((counter * 100 ) / items.count)%")
                    let model = CodeTableModel()
                    model.type = type
                    for item in items {
                        model.items.append(item)
                    }
                    RealmRequests.saveObject(object: model)
                    codeTables.append(model)
                    counter += 1
                }
                return completion(true)
            }
        })
        self.promise?.error({ (error, _) in
            ErrorLog(error)
            print(error)
        })
    }
    private func OLD_fetchAndStoreWaterBodiess(completion: @escaping (_ objects: [WaterBodyTableModel]) -> Void, status: @escaping(_ newStatus: String) -> Void) {
        //        Storage.shared.saveWaterBodiesFromJSON(status: status)
        //        return completion(Storage.shared.fullWaterBodyTables())
        
        
        status("Fetching Waterbodies")
        self.promise = waterBodyAPI.get()
        self.promise?.then({ (resp, _) in
            guard let data: [[String : Any]] = resp as? [[String: Any]] else {
                print("FAIL: Wrong resp")
                return completion([])
            }
            guard let _: [String: Any] = data.first else {
                print("FAIL: No first item")
                return completion([])
            }
            status("Storing Waterbodies")
            Storage.shared.deteleFullWaterBodyTables()
            DispatchQueue.global(qos: .background).async {
                var waterbodies: [WaterBodyTableModel] = []
                var counter = 1
                for item in data {
                    let model = WaterBodyTableModel()
                    status("Storing Waterbodies:\t\((counter * 100 ) / data.count)%")
                    counter += 1
                    model.name = item["name"] as? String ?? ""
                    model.water_body_id = item["water_body_id"] as? Int ?? 0
                    model.latitude = item["latitude"] as? Double ?? 0
                    model.longitude = item["longitude"] as? Double ?? 0
                    model.country = item["country"] as? String ?? ""
                    model.closest = item["closest"] as? String ?? ""
                    model.province = item["province"] as? String ?? ""
                    RealmRequests.saveObject(object: model)
                    waterbodies.append(model)
                }
                return completion(waterbodies)
            }
        })
    }
    
}
