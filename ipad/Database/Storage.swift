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
        checkForInvalidSubmissions()
        return getSyncableItems()
    }
    
    private func getSyncableItems() -> [ShiftModel] {
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
    
    private func checkForInvalidSubmissions() {
        let shifts = Storage.shared.getSyncableItems()
        var invalidShifts: [ShiftModel] = []
        for shift in shifts {
            if shift.shitEndComments.count > 300 || shift.shitStartComments.count > 300 {
                invalidShifts.append(shift)
                continue
            }
            if shift.station.isEmpty {
                invalidShifts.append(shift)
                continue
            }
            for inspection in shift.inspections where inspection.generalComments.count > 300 {
                invalidShifts.append(shift)
                continue
            }
        }
        
        for shift in invalidShifts {
            shift.set(shouldSync: false)
            for inspection in shift.inspections {
                inspection.set(shouldSync: false)
            }
        }
        
        if !invalidShifts.isEmpty {
            NotificationCenter.default.post(name: .shouldRefreshTable, object: nil)
            Alert.show(title: "Review your submissions", message: "Some of your records have been changed to darft state.\nPlease make sure all comment fields have at most 300 characters and that you have selected a station for all shifts before submitting.")
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
    public func inspection(withLocalId localId: String) -> WatercraftInspectionModel? {
        guard let realm = try? Realm(), let object = realm.objects(WatercraftInspectionModel.self).filter("localId = %@", localId).first else {
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
        return WaterbodiesService.shared.get()
    }
    
    public func fullMajorCitiesTables() -> [MajorCitiesTableModel] {
        return MajorCitiesService.shared.get()
    }
    
    public func getMajorCitiesDropdowns() -> [DropdownModel] {
        let majorCities = fullMajorCitiesTables()
        var CAN: [DropdownModel] = []
        var USA: [DropdownModel] = []
        var MEX: [DropdownModel] = []
        for majorCity in majorCities {
            if majorCity.country_code == "CAN" {
                CAN.append(DropdownModel(display: "\(majorCity.city_name), \(majorCity.province), \(majorCity.country_code)", key: "\(majorCity.major_city_id)"))
            }
            if majorCity.country_code == "USA" {
                USA.append(DropdownModel(display: "\(majorCity.city_name), \(majorCity.province), \(majorCity.country_code)", key: "\(majorCity.major_city_id)"))
            }
            if majorCity.country_code == "MEX" {
                MEX.append(DropdownModel(display: "\(majorCity.city_name), \(majorCity.province), \(majorCity.country_code)", key: "\(majorCity.major_city_id)"))
            }
        }
        return CAN.sorted(by: {$0.display < $1.display}) + USA.sorted(by: {$0.display < $1.display}) + MEX.sorted(by: {$0.display < $1.display})
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
        let waterbodies = fullWaterBodyTables()
        for waterbody in waterbodies where waterbody.water_body_id == id {
            return waterbody
        }
        return nil
    }
    
    public func getMajorCityModel(withId id: Int) -> MajorCitiesTableModel? {
        let majorCities = fullMajorCitiesTables()
        for majorCity in majorCities where majorCity.major_city_id == id {
            return majorCity
        }
        return nil
    }
    
    public func getWaterbodies(inProvince province: String) -> [String] {
        let waterbodies = fullWaterBodyTables()
        var result: [String] = []
        for waterbody in waterbodies where waterbody.province == province {
            result.append(waterbody.name)
        }
        return result
    }
    
    public func getWaterbodies(nearCity city: String) -> [String] {
        let waterbodies = fullWaterBodyTables()
        var result: [String] = []
        for waterbody in waterbodies where waterbody.closest == city {
            result.append(waterbody.name)
        }
        return result
    }
    
    public func getCities(nearWaterBody waterBody: String) -> [String] {
        let waterbodies = fullWaterBodyTables()
        var result: [String] = []
        for waterbodyModel in waterbodies where waterbodyModel.name == waterBody {
            result.append(waterbodyModel.closest)
        }
        return result
    }
    
    public func getCities(inProvince province: String) -> [String] {
        let waterbodies = fullWaterBodyTables()
        var result: [String] = []
        for waterbodyModel in waterbodies where waterbodyModel.province == province {
            result.append(waterbodyModel.closest)
        }
        return result
    }
        
    public func getProvinces(withWaterBody waterBody: String) -> [String] {
        let waterbodies = fullWaterBodyTables()
        var result: [String] = []
        for waterbodyModel in waterbodies where waterbodyModel.name == waterBody {
            result.append(waterbodyModel.province)
        }
        return result
    }
    
    public func getProvinces(withCity city: String) -> [String] {
       let waterbodies = fullWaterBodyTables()
        var result: [String] = []
        for waterbodyModel in waterbodies where waterbodyModel.closest == city {
            result.append(waterbodyModel.province)
        }
        return result
    }
}
