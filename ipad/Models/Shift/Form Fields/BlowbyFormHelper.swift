//
//  BlowByFormHelper.swift
//  ipad
//
//  Created by Sustainment Team on 2023-12-29.
//  Copyright © 2023 Sustainment Team. All rights reserved.
//

import Foundation

class BlowByFormHelper {
    /// Form Headers for Blowby information in a shift
    /// - Parameters:
    ///     - object: Model being used
    ///     - editable: Should the data display in a editable or static format?
    ///     - modalSize: Will be used in a scaled down
    ///  - Returns: [InputItems]
    static func getBlowByFields(for object: BlowbyModel? = nil, editable: Bool? = true, modalSize: Bool? = false) -> [InputItem] {
        var sectionItems: [InputItem] = []
        let timeStamp = TimeInput(
            key: "timeStamp",
            header: BlowbyFormHeaders.timeStamp,
            editable: editable ?? true,
            value: object?.timeStamp,
            width: .Third
        );
        sectionItems.append(timeStamp);

        let watercraftComplexity = DropdownInput (
            key: "watercraftComplexity",
            header: BlowbyFormHeaders.watercraftComplexity,
            editable: editable ?? true,
            value: object?.watercraftComplexity,
            width: .Third,
            dropdownItems: [
              DropdownModel(display: "Non-motorized", key: "Non-motorized"),
              DropdownModel(display: "Simple", key: "Simple"),
              DropdownModel(display: "Complex", key: "Complex"),
              DropdownModel(display: "Very Complex", key: "Very Complex")
            ]
        );
        sectionItems.append(watercraftComplexity);

        let reportedToRapp = SwitchInput(
            key: "reportedToRapp",
            header: BlowbyFormHeaders.reportedToRapp,
            editable: editable ?? true,
            value: object?.reportedToRapp,
            width: .Third
        );
        sectionItems.append(reportedToRapp)

        return sectionItems;
    }

    /// Column configuration for Blow By table
    /// - Returns: [TableViewColumnConfig]
    func getTableColumns() -> [TableViewColumnConfig] {
        var columns: [TableViewColumnConfig] = []
        columns.append(TableViewColumnConfig(key: "timeStamp", header: BlowbyFormHeaders.timeStamp, type: .Normal));
        columns.append(TableViewColumnConfig(key: "watercraftComplexity", header: BlowbyFormHeaders.watercraftComplexity, type: .Normal));
        columns.append(TableViewColumnConfig(key: "reportedToRapp", header: BlowbyFormHeaders.reportedToRapp, type: .Normal));
        return columns;
    }
}
