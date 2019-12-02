//
//  ShiftService.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-27.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Reachability

class ShiftService {
    static let shared = ShiftService()
    private init() {}
    
    private let shiftAPI: WorkflowAPI = WorkflowAPI.api()
    private let inspectionAPI: WatercraftRiskAssessmentAPI = WatercraftRiskAssessmentAPI.api()
    
    var promise: [String : Promise<RemoteResponse>?] = [String : Promise<RemoteResponse>]()
    
    public func submit(shift: ShiftModel, then: @escaping (_ success: Bool) -> Void) {
        let shiftLocalId = shift.localId
        // Post call
        post(shift: shift) { (shiftId) in
            // Fetch shift object - For realm thrad issues
            guard let rempteId = shiftId, let refetchedShift = Storage.shared.shift(withLocalId: shiftLocalId) else {
                return then(false)
            }
            refetchedShift.setRemote(id: rempteId)
            //            let dispatchGroup = DispatchGroup()
            //            var hadFailes = false
            //            for inspection in refetchedShift.inspections {
            //                let inspectionLocalId = inspection.localId
            //                dispatchGroup.enter()
            //                self.post(inspection: inspection, shift: rempteId) { (inspectId) in
            //                    if let inspectionId = inspectId, let referchedInspection = Storage.shared.inspection(withLocalId: inspectionLocalId) {
            //                        print(inspectionId)
            //                    } else {
            //                        hadFailes = true
            //                    }
            //                    dispatchGroup.leave()
            //                }
            //            }
            //            dispatchGroup.notify(queue: .main) {
            //                print("Shift Shibmission Executed.")
            //                return then(!hadFailes)
            //            }
            
            self.submit(inspections: Array(refetchedShift.inspections), shiftId: rempteId) { (success) in
                return then(success)
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
    
    private func post(shift: ShiftModel, then: @escaping (_ id: Int?) -> Void) {
        if (!isOnline()) {return then(nil)}
        self.promise[shift.localId] = shiftAPI.post(shift.toDictionary())
        self.promise[shift.localId]??.then({ (dat, resp) in
            guard let data = dat as? [String : Any] else {
                return then(nil)
            }
            let map: [String : Any] = resp as? [String : Any] ?? [:]
            if let id = data["observer_workflow_id"] as? Int {
                return then(id)
            } else {
                return then(nil)
            }
        })
        self.promise[shift.localId]??.error({ (e, _) in
            print("Error during Shift POST")
            print(e)
            return then(nil)
        })
    }
    
    private func post(inspection: WatercradftInspectionModel, shift id: Int,then: @escaping (_ id: Int?) -> Void) {
        if (!isOnline()) {return then(nil)}
        self.promise[inspection.localId] = inspectionAPI.post(inspection.toDictionary(shift: id))
        self.promise[inspection.localId]??.then({ (dat, resp) in
            
            guard let data = dat as? [String : Any] else {
                return then(nil)
            }
            let map: [String : Any] = resp as? [String : Any] ?? [:]
            if let id = data["observer_workflow_id"] as? Int {
                return then(id)
            } else {
                return then(nil)
            }
        })
        self.promise[inspection.localId]??.error({ (e, _) in
            print("Error during Inspection POST")
            print(e)
            return then(nil)
        })
    }
    
    // Submit inspection objects recursively
    private func submit(inspections: [WatercradftInspectionModel], shiftId: Int,then: @escaping (_ success: Bool) -> Void) {
        var remainingInspections = inspections
        if remainingInspections.count < 1 {
            return then(true)
        }
        guard isOnline(), let inspection = remainingInspections.popLast() else {
            return then(false)
        }
        let inspectionLocalId = inspection.localId
        self.promise[inspection.localId] = inspectionAPI.post(inspection.toDictionary(shift: shiftId))
        self.promise[inspection.localId]??.then({ (dat, resp) in
            guard let data = dat as? [String : Any] else {
                return then(false)
            }
            if
                let shiftRemoteid = data["watercraft_risk_assessment_id"] as? Int,
                let refetchedInspection = Storage.shared.inspection(withLocalId: inspectionLocalId)
            {
                refetchedInspection.setRemote(id: shiftRemoteid)
                self.submit(inspections: remainingInspections, shiftId: shiftId, then: then)
            } else {
                return then(false)
            }
        })
        self.promise[inspection.localId]??.error({ (e, _) in
            print("Error during Inspection POST")
            print(e)
            return then(false)
        })
    }
}
