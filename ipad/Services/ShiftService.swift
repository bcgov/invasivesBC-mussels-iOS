//
//  ShiftService.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-27.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import SwiftyJSON
import Realm
import RealmSwift
import Reachability

class ShiftService {
    static let shared = ShiftService()
    private init() {}
    
    private let shiftAPI: WorkflowAPI = WorkflowAPI.api()
    private let inspectionAPI: WatercraftRiskAssessmentAPI = WatercraftRiskAssessmentAPI.api()
    
    var promise: [String : Promise<RemoteResponse>?] = [String : Promise<RemoteResponse>]()
    
    public func submit(shifts: [ShiftModel], then: @escaping (_ success: Bool) -> Void) {
        var remainingShifts = shifts
        if remainingShifts.count < 1 {
            return then(true)
        }
        
        guard isOnline(), let shift = remainingShifts.popLast() else {
            return then(false)
        }
        let shiftId = shift.localId
         submit(shift: shift) { (submittedShift) in
            if submittedShift, let refetchedShift = Storage.shared.shift(withLocalId: shiftId) {
                refetchedShift.set(shouldSync: false)
                refetchedShift.set(status: .Completed)
                for inspection in refetchedShift.inspections {
                    inspection.set(shouldSync: false)
                    inspection.set(status: .Completed)
                }
                return self.submit(shifts: remainingShifts, then: then)
            } else {
                return then(false)
            }
        }
    }
    
     public func submit(shift: ShiftModel, then: @escaping (_ success: Bool) -> Void) {
        let shiftLocalId = shift.localId
        // Post call
        post(shift: shift) { (shiftId) in
            guard let remoteId = shiftId, let refetchedShift = Storage.shared.shift(withLocalId: shiftLocalId) else {
                return then(false)
            }
            refetchedShift.set(remoteId: remoteId)

            var inspectionSuccess = false
            var blowBySuccess = false

            let group = DispatchGroup()

            group.enter()
            self.submit(inspections: Array(refetchedShift.inspections), shiftId: remoteId) { (success) in
                inspectionSuccess = success
                group.leave()
            }

            group.enter()
            self.submit(theBlowBys: Array(refetchedShift.blowbys), shiftId: remoteId) { (success) in
                blowBySuccess = success
                group.leave()
            }

            // Wait for both submissions to complete
            group.notify(queue: .main) {
                return then(inspectionSuccess && blowBySuccess)
            }
        }
     }


    
    private func isOnline() -> Bool {
        do {
            let reachability = try Reachability()
            if reachability.connection == .unavailable {
                return false
            }
        } catch let error as NSError {
            print("** Reachability ERROR")
            print(error)
            return false
        }
        return true
    }
    
    private func showError(in json: JSON) {
        var message = ""
        if let apiMessage = json["message"].string {
            message = apiMessage
        }
        var errors: String = ""
        if let apiErrors = json["errors"].array {
            for error in apiErrors {
                guard let msg = error["msg"].string else {continue}
                errors = "\(errors)*Error:\n\(msg)\n"
            }
        }
        print(errors)
        DispatchQueue.main.async {
            Banner.show(message: message, detail: errors)
        }
    }
    
    private func post(shift: ShiftModel, then: @escaping (_ id: Int?) -> Void) {
        if (!isOnline()) {return then(nil)}
        guard let endpoint = URL(string: APIURL.workflow) else { return then(nil)}
        APIRequest.request(type: .Post, endpoint: endpoint, params: shift.toDictionary()) { (result) in
            guard let responseJSON = result else {
                Banner.show(message: "Didn't receive a valid API response when posting shift")
                return then(nil)
            }
            guard let dataDict = responseJSON["data"].dictionary, let id = dataDict["observer_workflow_id"]?.int else {
                self.showError(in: responseJSON)
                return then(nil)
            }
            return then(id)
        }
    }
    
    private func post(inspection: WatercraftInspectionModel, shift id: Int,then: @escaping (_ id: Int?) -> Void) {
        if (!isOnline()) {return then(nil)}
        guard let endpoint = URL(string: APIURL.watercraftRiskAssessment) else { return then(nil)}
        APIRequest.request(type: .Post, endpoint: endpoint, params: inspection.toDictionary(shift: id)) { (result) in
            guard let responseJSON = result else {
                Banner.show(message: "Didn't receive a valid API response when posting inspection")
                return then(nil)
            }
            guard let dataDict = responseJSON["data"].dictionary, let id = dataDict["watercraft_risk_assessment_id"]?.int else {
                self.showError(in: responseJSON)
                return then(nil)
            }
            return then(id)
        }
    }
    
    private func post(blowBy: BlowbyModel, shift id: Int,then: @escaping (_ id: Int?) -> Void) {
        if (!isOnline()) {return then(nil)}
        guard let endpoint = URL(string: APIURL.blowBys) else { return then(nil)}
        APIRequest.request(type: .Post, endpoint: endpoint, params: blowBy.toDictionary(shift: id)) { (result) in
            guard let responseJSON = result else {
                Banner.show(message: "Didn't receive a valid API response when posting blow by")
                return then(nil)
            }
            guard let dataDict = responseJSON["data"].dictionary, let id = dataDict["blow_by_id"]?.int else {
                self.showError(in: responseJSON)
                return then(nil)
            }
            return then(id)
        }
    }
    
    // Submit inspection objects recursively
    private func submit(inspections: [WatercraftInspectionModel], shiftId: Int,then: @escaping (_ success: Bool) -> Void) {
        var remainingInspections = inspections
        if remainingInspections.count < 1 {
            return then(true)
        }
        guard isOnline(), let inspection = remainingInspections.popLast() else {
            return then(false)
        }
        let inspectionLocalId = inspection.localId
        
        post(inspection: inspection, shift: shiftId) { (inspectionId) in
            guard let id = inspectionId, let refetchedInspection = Storage.shared.inspection(withLocalId: inspectionLocalId) else {
                return then(false)
            }
            refetchedInspection.set(remoteId: id)
            self.submit(inspections: remainingInspections, shiftId: shiftId, then: then)
        }
    }

    // Submit blowby objects recursively
     private func submit(theBlowBys: [BlowbyModel], shiftId: Int, then: @escaping (_ success: Bool) -> Void) {
          var remainingBlowBys = theBlowBys
          if remainingBlowBys.count < 1 {
               return then(true)
          }
          guard isOnline() else {
               return then(false)
          }
          
          guard let theBlowBy = remainingBlowBys.popLast() else {
               return then(false)
          }
          let blowByLocalId = theBlowBy.localId
          
          post(blowBy: theBlowBy, shift: shiftId) { (blowById) in
               guard let id = blowById, let refetchedBlowBy = Storage.shared.blowBy(withLocalId: blowByLocalId) else {
                    return then(false)
               }
               refetchedBlowBy.set(remoteId: id)
               self.submit(theBlowBys: remainingBlowBys, shiftId: shiftId, then: then)
          }
     }
}
