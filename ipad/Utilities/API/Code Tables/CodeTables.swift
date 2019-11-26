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
}

class CodeTables {
    
    static let shared = CodeTables()
    private init() {}
    
    private let waterBodyAPI: WaterBodyAPI =  WaterBodyAPI.api()
    private let codesAPI: CodesAPI = CodesAPI.api()
    
    var promise: Promise<RemoteResponse>?
    
    public func fetchCodes(completion: @escaping(_ success: Bool) -> Void) {
        fetchAndStoreCodes { (codes) in
            if codes.count > 0 {
                self.fetchAndStoreWaterBodies { (waterBodies) in
                    return completion(waterBodies.count > 0)
                }
            } else {
                return completion(false)
            }
        }
    }
    
    private func fetchAndStoreCodes(completion: @escaping (_ objects: [CodeTableModel]) -> Void) {
        do {
            let reacahbility = try Reachability()
            if (reacahbility.connection == .unavailable) {
                return completion([])
            }
        } catch let error as NSError {
            print("** Reachability ERROR")
            print(error)
        }
        
        self.promise = codesAPI.get()
        self.promise?.then({ (resp, _) in
            guard let data: [String: Any] = resp as? [String: Any] else {
                print("FAIL: Wrong resp")
                return completion([])
            }
            Storage.shared.deleteCodeTables()
            var codeTables: [CodeTableModel] = []
            for (type, items) in data {
                guard let items = items as? [String] else {
                    continue
                }
                let model = CodeTableModel()
                model.type = type
                for item in items {
                    model.items.append(item)
                }
                RealmRequests.saveObject(object: model)
                codeTables.append(model)
            }
            return completion(codeTables)
        })
    }
    
    private func fetchAndStoreWaterBodies(completion: @escaping (_ objects: [WaterBodyTableModel]) -> Void) {
        
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
            Storage.shared.deteleWaterBodyTables()
            var waterbodies: [WaterBodyTableModel] = []
            for item in data {
                let model = WaterBodyTableModel()
                model.name = item["name"] as? String ?? ""
                model.water_body_id = item["water_body_id"] as? Int ?? 0
                model.latitude = item["latitude"] as? Double ?? 0
                model.longitude = item["longitude"] as? Double ?? 0
                model.abbrev = item["abbrev"] as? String ?? ""
                model.closest = item["closest"] as? String ?? ""
                RealmRequests.saveObject(object: model)
                waterbodies.append(model)
            }
            return completion(waterbodies)
        })
    }
    
}
