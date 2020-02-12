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

public enum CodeTableType {
    case observers
    case otherObservations
    case stations
    case watercraftList
    case waterBodies
    case cities
    case provinces
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
        status("Fetching code tables")
        delayWithSeconds(1) {
            self.fetchAndStoreCodes(completion: { (codes) in
                if codes.count < 0 { return completion(false) }
                status("Loading Waterbodies")
                self.fetchAndStoreWaterBodies(completion: { (waterBodies) in
                    if waterBodies.count < 0 { return completion(false) }
                    status("Wrapping up")
                    let provinces = waterBodies.map{$0.country}.uniques.sorted{$0.lowercased() < $1.lowercased()}
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
                    
                    return completion(true)
                }) { (statusUpdate) in
                   status(statusUpdate)
                }
            }, status: status)
        }
    }
    
    private func fetchAndStoreCodes(completion: @escaping (_ objects: [CodeTableModel]) -> Void, status: @escaping(_ newStatus: String) -> Void) {
        do {
            let reacahbility = try Reachability()
            if (reacahbility.connection == .unavailable) {
                return completion([])
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
                return completion([])
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
                return completion(codeTables)
            }
        })
        self.promise?.error({ (error, _) in
            ErrorLog(error)
            print(error)
        })
    }
    
    private func fetchAndStoreWaterBodies(completion: @escaping (_ objects: [WaterBodyTableModel]) -> Void, status: @escaping(_ newStatus: String) -> Void) {
//        Storage.shared.saveWaterBodiesFromJSON(status: status)
//        return completion(Storage.shared.fullWaterBodyTables())
        do {
            let reacahbility = try Reachability()
            if (reacahbility.connection == .unavailable) {
                return completion([])
            }
        } catch  let error as NSError {
            print("** Reachability ERROR")
            print(error)
            return completion([])
        }
        
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
    
    func findWaterbody(name: String, province: String, nearestCity: String) -> WaterBodyTableModel? {
        let allWaterbodies = Storage.shared.fullWaterBodyTables()
        for element in allWaterbodies where element.name == name && element.country == province && element.closest == nearestCity {
            return element
        }
        return nil
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
}
