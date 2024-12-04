//
//  ShiftFormHelper.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-25.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation


/// Helper class for producing input fields for Shiftmodels
class ShiftFormHelper {
  
  /// Gets the required Input objects needed for the ShiftStartFields section of shift
  /// - Parameters:
  ///   - object: Instance of the ShiftModel
  ///   - editable: Will forms be editable, or viewable only
  ///   - modalSize: Small rendering of components, or regular size rendering of components
  /// - Returns: [InputItems] Form input items
    static func getShiftStartFields(for object: ShiftModel? = nil, editable: Bool? = true, modalSize: Bool? = false) -> [InputItem] {
        var sectionItems: [InputItem] = []
        
        let shiftStartDate = DateInput(
            key: "shiftStartDate",
            header: ShiftFormHeaders.ShiftStart.shiftStartDate,
            editable: editable ?? true,
            value: object?.shiftStartDate ?? Date(),
            width: .Third
        )
        sectionItems.append(shiftStartDate)
        
        let startTime = TimeInput(
            key: "startTime",
            header: ShiftFormHeaders.ShiftStart.startTime,
            editable: editable ?? true,
            value: object?.startTime ?? "",
            width: .Third
        )
        sectionItems.append(startTime)
        
        let station = DropdownInput(
            key: "station",
            header: ShiftFormHeaders.ShiftStart.station,
            editable: editable ?? true,
            value: object?.station,
            width: .Third,
            dropdownItems: DropdownHelper.shared.getDropdown(for: .stations)
        )
        sectionItems.append(station)

        let shiftStartComments = TextAreaInput(
            key: "shiftStartComments",
            header: ShiftFormHeaders.ShiftStart.comments,
            editable: editable ?? true,
            value: object?.shiftStartComments ?? "",
            width: .Full
        )
        sectionItems.append(shiftStartComments)

        let stationComments = TextAreaInput(
            key: "stationComments",
            header: ShiftModel.stationRequired(object?.station ?? "") 
                ? ShiftFormHeaders.ShiftStart.stationCommentsRequired 
                : ShiftFormHeaders.ShiftStart.stationComments,
            editable: editable ?? true,
            value: object?.stationComments ?? "",
            width: .Full
        )

        sectionItems.append(stationComments)

        return sectionItems
    }
  /// Gets the required Input objects needed for the ShiftEndFields section of shift
  /// - Parameters:
  ///   - object: Instance of the ShiftModel
  ///   - editable: Will forms be editable, or viewable only
  /// - Returns: [InputItems] Form input items
    static func getShiftEndFields(for object: ShiftModel? = nil, editable: Bool? = true) -> [InputItem] {
        var sectionItems: [InputItem] = []
        
        let endTime = TimeInput(
            key: "endTime",
            header: ShiftFormHeaders.ShiftEnd.endTime,
            editable: editable ?? true,
            value: object?.endTime ?? "",
            width: .Third
        )
        sectionItems.append(endTime)
        
        let k9OnShift = SwitchInput(
            key: "k9OnShif",
            header: ShiftFormHeaders.ShiftStart.k9OnShift,
            editable: editable ?? true,
            value: object?.k9OnShif,
            width: .Third
        )
        sectionItems.append(k9OnShift)
        
        let boatsInspected = SwitchInput(
            key: "boatsInspected",
            header: ShiftFormHeaders.ShiftEnd.boatsInspected,
            editable: editable ?? true,
            value: object?.boatsInspected,
            width: .Third
        )
      sectionItems.append(boatsInspected)
        let shiftEndComments = TextAreaInput(
            key: "shiftEndComments",
            header: ShiftFormHeaders.ShiftEnd.comments,
            editable: editable ?? true,
            value: object?.shiftEndComments ?? "",
            width: .Full
        )
        sectionItems.append(shiftEndComments)
        
        return sectionItems
    }
    
  
  /// Return the columns for displaying Shift Overview information
  /// - Returns: [TableViewColumnConfig]  Array of table column configuration objects
    func getTableColumns() -> [TableViewColumnConfig] {
        // Create Column Config
        var columns: [TableViewColumnConfig] = []
        columns.append(TableViewColumnConfig(key: "remoteId", header: "Shift ID", type: .Normal))
        columns.append(TableViewColumnConfig(key: "riskLevel", header: "Shift Date", type: .Normal))
        columns.append(TableViewColumnConfig(key: "timeAdded", header: "Station Location", type: .Normal))
        columns.append(TableViewColumnConfig(key: "status", header: "Status", type: .WithIcon))
        columns.append(TableViewColumnConfig(key: "", header: "Actions", type: .Button, buttonName: "View", showHeader: false))
        return columns
    }
    
}
