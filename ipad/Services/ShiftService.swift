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
    
    /// Submits a collection of shifts to the server.
    ///
    /// This function takes an array of `ShiftModel` instances and attempts to submit them to the server.
    /// The submission process involves checking if the device is online and then iteratively submitting each shift.
    /// Once a shift is successfully submitted, it updates the status of the shift and its associated inspections in local storage.
    /// If the submission of a shift fails, the function stops the submission process and returns false.
    ///
    /// - Parameters:
    ///  - shifts: An array of `ShiftModel` instances representing the shifts to be submitted.
    ///  - then: A closure that gets called once all shifts have been submitted. It receives a boolean indicating whether the operation was successful.
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
    
    /// Submits a single shift to the server.
    ///
    /// This function takes a `ShiftModel` instance and attempts to submit it to the server.
    /// The submission process involves making a POST request to the server with the shift data.
    /// Once the shift is successfully submitted, it updates the remote ID of the shift and its associated inspections and blowbys in local storage.
    /// If the submission of the shift fails, the function returns false.
    ///
    /// - Parameters:
    ///  - shift: A `ShiftModel` instance representing the shift to be submitted.
    ///  - then: A closure that gets called once the shift has been submitted. It receives a boolean indicating whether the operation was successful.
    public func submit(shift: ShiftModel, then: @escaping (_ success: Bool) -> Void) {
        let shiftLocalId = shift.localId
        if(!shift.inspections.allSatisfy(){item in return item.formDidValidate}) {
          shift.set(shouldSync: false)
          shift.set(status: .Errors)
          shift.inspections.forEach(){inspection in
            if (!inspection.formDidValidate){
              inspection.set(shouldSync: false)
              inspection.set(status: .Errors)
            }
          }
          Alert.show(title: "Submission Error", message: "A shift contains non-validated inspections, please re-visit inspections and correct outstanding issues")
          return then(false);
        }
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
    
    /// Makes a POST request to the server with the shift data.
    ///
    /// This function takes a `ShiftModel` instance and attempts to send it to the server using a POST request.
    /// The function checks if the device is online before making the request.
    /// If the device is not online or if the request fails, the function returns nil.
    /// Otherwise, it extracts the `observer_workflow_id` from the response and returns it.
    ///
    /// - Parameters:
    ///  - shift: A `ShiftModel` instance representing the shift data to be sent to the server.
    ///  - then: A closure that gets called once the request is completed. It receives the `observer_workflow_id` from the server response, or nil if the request failed or the device is not online.
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
    
    /// Makes a POST request to the server with the inspection data.
    ///
    /// This function takes a `WatercraftInspectionModel` instance and attempts to send it to the server using a POST request.
    /// The function checks if the device is online before making the request.
    /// If the device is not online or if the request fails, the function returns nil.
    /// Otherwise, it extracts the `watercraft_risk_assessment_id` from the response and returns it.
    ///
    /// - Parameters:
    ///  - inspection: A `WatercraftInspectionModel` instance representing the inspection data to be sent to the server.
    ///  - shift: The ID of the shift to which the inspection belongs.
    ///  - then: A closure that gets called once the request is completed. It receives the `watercraft_risk_assessment_id` from the server response, or nil if the request failed or the device is not online.
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
    
    /// Makes a POST request to the server with the blow by data.
    ///
    /// This function takes a `BlowbyModel` instance and attempts to send it to the server using a POST request.
    /// The function checks if the device is online before making the request.
    /// If the device is not online or if the request fails, the function returns nil.
    /// Otherwise, it extracts the `blow_by_id` from the response and returns it.
    ///
    /// - Parameters:
    ///  - blowBy: A `BlowbyModel` instance representing the blow by data to be sent to the server.
    ///  - shift: The ID of the shift to which the blow by belongs.
    ///  - then: A closure that gets called once the request is completed. It receives the `blow_by_id` from the server response, or nil if the request failed or the device is not online.
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
    
    /// Recursively submits a collection of inspections to the server.
    ///
    /// This function takes an array of `WatercraftInspectionModel` instances and attempts to submit them to the server.
    /// The submission process involves checking if the device is online and then iteratively submitting each inspection.
    /// Once an inspection is successfully submitted, it updates the remote ID of the inspection in local storage.
    /// If the submission of an inspection fails, the function stops the submission process and returns false.
    ///
    /// - Parameters:
    /// - inspections: An array of `WatercraftInspectionModel` instances representing the inspections to be submitted.
    /// - shiftId: The ID of the shift to which the inspections belong.
    /// - then: A closure that gets called once all inspections have been submitted. It receives a boolean indicating whether the operation was successful.
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
    
    /// Recursively submits a collection of blowbys to the server.
    ///
    /// This function takes an array of `BlowbyModel` instances and attempts to submit them to the server.
    /// The submission process involves checking if the device is online and then iteratively submitting each blowby.
    /// Once a blowby is successfully submitted, it updates the remote ID of the blowby in local storage.
    /// If the submission of a blowby fails, the function stops the submission process and returns false.
    ///
    /// - Parameters:
    /// - theBlowBys: An array of `BlowbyModel` instances representing the blowbys to be submitted.
    /// - shiftId: The ID of the shift to which the blowbys belong.
    /// - then: A closure that gets called once all blowbys have been submitted. It receives a boolean indicating whether the operation was successful.
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
