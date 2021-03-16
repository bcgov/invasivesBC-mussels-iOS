//
//  WaterbodiesService.swift
//  ipad
//
//  Created by Amir Shayegh on 2020-05-19.
//  Copyright © 2020 Amir Shayegh. All rights reserved.
//

import Foundation
import SwiftyJSON

class WaterbodiesService {
    public static var shared = WaterbodiesService()
    private var table: [WaterBodyTableModel] = []
    private var fileName: String = "waterbodies"
    private init() {
        loadTable()
    }
    
    public func fetchAndStoreWaterBodies(completion: @escaping (_ success: Bool) -> Void, status: @escaping(_ newStatus: String) -> Void) {
        fetchWaterBodies { (response) in
            guard let data = response else {
                return completion(false)
            }
            do {
                try data.write(to: self.waterbodiesDirectoryPath())
                self.loadTable()
                return completion(true)
            } catch {
                print(error)
                print("Write Error WaterbodiesService -> fetchAndStoreWaterBodies()")
                return completion(false)
            }
        }
    }
    
    public func get() -> [WaterBodyTableModel] {
        return table
    }
    
    // MARK: Read
    private func loadTable() {
        guard waterbodiesExist() else {return}
        guard let data = getData(at: waterbodiesDirectoryPath()) else {return}
        guard let dataArray = data.array else {return}
        table.removeAll()
        for entry in dataArray {
            guard let dictionary = entry.dictionary, let object = process(dictionary: dictionary) else {
                continue
            }
            table.append(object)
        }
    }
    
    private func process(dictionary: [String: Any]) -> WaterBodyTableModel? {
        let model = WaterBodyTableModel()
        model.name = (dictionary["name"] as? JSON)?.string ?? ""
        model.water_body_id = (dictionary["water_body_id"] as? JSON)?.int ?? 0
        model.latitude = (dictionary["latitude"] as? JSON)?.double ?? 0
        model.longitude = (dictionary["longitude"] as? JSON)?.double ?? 0
        model.country = (dictionary["country"] as? JSON)?.string ?? ""
        model.closest = (dictionary["closest"] as? JSON)?.string ?? ""
        model.province = (dictionary["province"] as? JSON)?.string ?? ""
        if model.water_body_id > 0 {
            return model
        } else {
            return nil
        }
    }
    
    private func waterbodiesExist() -> Bool {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    private func getData(at path: URL) -> JSON? {
        do {
            let data = try Data(contentsOf: path)
            let json = try JSON(data: data)
            return json
        } catch {
            print("Error in WaterbodiesService -> getData()")
            return nil
        }
    }
    
    // MARK: API
    private func fetchWaterBodies(then: @escaping(Data?)->Void) {
        guard let url = URL(string: APIURL.waterBody) else {return then(nil)}
        APIRequest.request(type: .Get, endpoint: url) { (_response) in
            guard let response = _response else {return then(nil)}
            let data = response["data"]
            do {
                let rawdata = try data.rawData()
                return then(rawdata)
            } catch {
                return then(nil)
            }
        }
    }
    
    // MARK: Documents Directory
    private func waterbodiesDirectoryPath() -> URL {
        let documentsDirectory = documentDirectoryPath()
        let dirPath = documentsDirectory.appendingPathComponent(fileName)
        return dirPath
    }
    
    
    private func documentDirectoryPath() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    
    
}
