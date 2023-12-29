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
    static func getBlowByStartFields(for object: BlowByModel? = nil, editable: Bool? = true, modalSize: Bool? = false) -> [InputItem] {
        var sectionItems: [InputItem] = []
        let blowByTime = TimeInput(
            key: "blowByTime",
            header: BlowByFormHeaders.blowByTime,
            editable: editable ?? true,
            value: object?.blowByTime,
            width: .Third
        );
        sectionItems.append(blowByTime);
        
        let watercraftComplexity = DropdownInput (
            key: "watercraftComplexity",
            header: BlowByFormHeaders.watercraftComplexity,
            editable: editable ?? true,
            value: object?.watercraftComplexity,
            width: .Third,
            dropdownItems: DropdownHelper.shared.getDropdown(for: .stations)
        );
        sectionItems.append(watercraftComplexity);
        
        let reportedToRapp = SwitchInput(
            key: "reportedToRapp",
            header: BlowByFormHeaders.reportedToRapp,
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
        columns.append(TableViewColumnConfig(key: "blowByTime", header: BlowByFormHeaders.blowByTime, type: .Normal));
        columns.append(TableViewColumnConfig(key: "watercraftComplexity", header: BlowByFormHeaders.watercraftComplexity, type: .Normal));
        columns.append(TableViewColumnConfig(key: "reportedToRapp", header: BlowByFormHeaders.reportedToRapp, type: .Normal));
        return columns;
    }
}
