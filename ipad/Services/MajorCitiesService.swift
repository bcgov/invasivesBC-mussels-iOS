//
//  MajorCitiesService.swift
//  ipad
//
//  Created by Warren, Sam on 2021-02-08.
//  Copyright © 2021 Amir Shayegh. All rights reserved.
//

import Foundation
import SwiftyJSON

class MajorCitiesService {
    public static var shared = MajorCitiesService()
    private var table: [MajorCitiesTableModel] = []
    private var fileName: String = "majorcities"
    private init() {
        loadTable()
    }
    
    public func fetchAndStoreMajorCities(completion: @escaping (_ success: Bool) -> Void, status: @escaping(_ newStatus: String) -> Void) {
        fetchMajorCities { (response) in
            guard let data = response else {
                return completion(false)
            }
            do {
                try data.write(to: self.majorCitiesDirectoryPath())
                self.loadTable()
                return completion(true)
            } catch {
                print(error)
                print("Write Error MajorCitiesService -> fetchAndStoreMajorCities()")
                return completion(false)
            }
        }
    }
    
    public func get() -> [MajorCitiesTableModel] {
        return table
    }
    
    // MARK: Read
    private func loadTable() {
        guard majorCitiesExist() else {return}
        guard let data = getData(at: majorCitiesDirectoryPath()) else {return}
        guard let dataArray = data.array else {return}
        table.removeAll()
        for entry in dataArray {
            guard let dictionary = entry.dictionary, let object = process(dictionary: dictionary) else {
                continue
            }
            table.append(object)
        }
    }
    
    private func process(dictionary: [String: Any]) -> MajorCitiesTableModel? {
        let model = MajorCitiesTableModel()
        model.city_name = (dictionary["city_name"] as? JSON)?.string ?? ""
        model.city_latitude = (dictionary["city_latitude"] as? JSON)?.double ?? 0
        model.city_longitude = (dictionary["city_longitude"] as? JSON)?.double ?? 0
        model.country_code = (dictionary["country_code"] as? JSON)?.string ?? ""
        model.closest_water_body = (dictionary["closest_water_body"] as? JSON)?.string ?? ""
        model.province = (dictionary["province"] as? JSON)?.string ?? ""
        model.distance = (dictionary["distance"] as? JSON)?.double ?? 0
        model.major_city_id = (dictionary["major_city_id"] as? JSON)?.int ?? 0
        return model
    }
    
    private func majorCitiesExist() -> Bool {
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
            print("Error in MajorCitiesService -> getData()")
            return nil
        }
    }
    
    // MARK: API
    private func fetchMajorCities(then: @escaping(Data?)->Void) {
        guard let url = URL(string: APIURL.majorCities) else {return then(nil)}
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
    private func majorCitiesDirectoryPath() -> URL {
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
