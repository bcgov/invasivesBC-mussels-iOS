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
    case decontaminationOrderReasons
    case daysOutOfWater
    case previousAISKnowledgeSource
    case previousInspectionSource
    case countryProvince
}

class CodeTableService {
    
    static let shared = CodeTableService()
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
        let req = APIRequest.fetchCodeTables { (response) in
            // Check for failure
            debugPrint("** RESPONSE!!! ", response);
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
        debugPrint("** REQUEST!!! ", req);
    }
    
    private func processCountryProvinceTable(input: [[String : Any]]) -> CodeTableModel {
        let table: CodeTableModel = CodeTableModel()
        for item in input {
            let code: CountryProvince = CountryProvince()
            code.des = item["displayLabel"] as? String ?? ""
            code.country = item["countryCode"] as? String ?? ""
            code.province = item["provinceCode"] as? String ?? ""
            table.provinces.append(code)
        }
        table.type = "countryProvince"
        return table
    }
    
    private func processCodeTableJSON(dict: [String: Any]) -> [CodeTableModel]{
        var codeTables: [CodeTableModel] = []
        
        for (key, value) in dict {
            guard let itemJSON: [JSON] = value as? [JSON] else {
                ErrorLog("Unexpected code array received")
                continue
            }
            let tempCodeItems = itemJSON.map { $0.dictionaryObject }
            // Check for CountryProvince : countryProvince
            if let items = tempCodeItems as? [[String : Any]], key == "countryProvince" {
                // Proccess countryProvince
                codeTables.append(self.processCountryProvinceTable(input: items))
                continue
            }
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
        WaterbodiesService.shared.fetchAndStoreWaterBodies(completion: completion, status: status)
    }
    
    func findWaterbody(name: String, province: String, nearestCity: String) -> WaterBodyTableModel? {
        let allWaterbodies = Storage.shared.fullWaterBodyTables()
        for element in allWaterbodies where element.name == name && element.country == province && element.closest == nearestCity {
            return element
        }
        return nil
    }
}
