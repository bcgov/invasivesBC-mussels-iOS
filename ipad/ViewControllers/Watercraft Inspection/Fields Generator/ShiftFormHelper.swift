//
//  ShiftFormHelper.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-25.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation

class ShiftFormHelper {
    private static func getDummyOptions() -> [DropdownModel]{
        var options: [DropdownModel] = []
        options.append(DropdownModel(display: "Something here"))
        options.append(DropdownModel(display: "Something else here"))
        options.append(DropdownModel(display: "Something more here"))
        options.append(DropdownModel(display: "Another thing"))
        return options
    }
    
    static func getShiftModalFields(for object: ShiftModel? = nil, editable: Bool? = true, modalSize: Bool? = false) -> [InputItem] {
        let isModalSize = modalSize ?? false
        var sectionItems: [InputItem] = []
        
        let startTime = TimeInput(
            key: "startTime",
            header: ShiftFormHeaders.ShiftStart.startTime,
            editable: editable ?? true,
            value: object?.startTime ?? nil,
            width: isModalSize ? .Half : .Third
        )
        sectionItems.append(startTime)
        
        let k9OnShift = SwitchInput(
            key: "k9OnShif",
            header: ShiftFormHeaders.ShiftStart.k9OnShift,
            editable: editable ?? true,
            value: object?.k9OnShif,
            width: isModalSize ? .Half : .Third
        )
        sectionItems.append(k9OnShift)
        
        let station = DropdownInput(
            key: "station",
            header: ShiftFormHeaders.ShiftStart.station,
            editable: editable ?? true,
            value: object?.station,
            width: isModalSize ? .Full : .Third,
            dropdownItems: getDummyOptions()
        )
        sectionItems.append(station)
        
        let sunny = RadioBoolean(
            key: "sunny",
            header: ShiftFormHeaders.ShiftStart.sunny,
            editable: editable ?? true,
            value: object?.sunny,
            width: .Forth
        )
        sectionItems.append(sunny)
        
        let cloudy = RadioBoolean(
            key: "cloudy",
            header: ShiftFormHeaders.ShiftStart.cloudy,
            editable: editable ?? true,
            value: object?.cloudy,
            width: .Forth
        )
        sectionItems.append(cloudy)
        
        let raining = RadioBoolean(
            key: "raining",
            header: ShiftFormHeaders.ShiftStart.raining,
            editable: editable ?? true,
            value: object?.raining,
            width: .Forth
        )
        sectionItems.append(raining)
        
        let snowing = RadioBoolean(
            key: "snowing",
            header: ShiftFormHeaders.ShiftStart.snowing,
            editable: editable ?? true,
            value: object?.snowing,
            width: .Forth
        )
        sectionItems.append(snowing)
        
        let foggy = RadioBoolean(
            key: "foggy",
            header: ShiftFormHeaders.ShiftStart.foggy,
            editable: editable ?? true,
            value: object?.foggy,
            width: .Forth
        )
        sectionItems.append(foggy)
        
        let windy = RadioBoolean(
            key: "windy",
            header: ShiftFormHeaders.ShiftStart.windy,
            editable: editable ?? true,
            value: object?.windy,
            width: .Forth
        )
        sectionItems.append(windy)
        
        let shitStartComments = TextAreaInput(
            key: "shitStartComments",
            header: ShiftFormHeaders.ShiftStart.comments,
            editable: editable ?? true,
            value: object?.shitStartComments ?? "",
            width: .Full
        )
        sectionItems.append(shitStartComments)
        
        return sectionItems
    }
    
    static func getShiftEndFields(for object: ShiftModel? = nil, editable: Bool? = true) -> [InputItem] {
        var sectionItems: [InputItem] = []
        
        let endTime = TimeInput(
            key: "endTime",
            header: ShiftFormHeaders.ShiftEnd.endTime,
            editable: editable ?? true,
            value: object?.endTime ?? nil,
            width: .Forth
        )
        sectionItems.append(endTime)
        
        let boatsInspected = SwitchInput(
            key: "boatsInspected",
            header: ShiftFormHeaders.ShiftEnd.boatsInspected,
            editable: editable ?? true,
            value: object?.boatsInspected,
            width: .Forth
        )
        sectionItems.append(boatsInspected)
        
        let motorizedBlowBys = IntegerStepperInput(
            key: "motorizedBlowBys",
            header: ShiftFormHeaders.ShiftEnd.motorizedBlowBys,
            editable: editable ?? true,
            value: object?.motorizedBlowBys,
            width: .Forth
        )
        sectionItems.append(motorizedBlowBys)
        
        let nonMotorizedBlowBys = IntegerStepperInput(
            key: "nonMotorizedBlowBys",
            header: ShiftFormHeaders.ShiftEnd.nonMotorizedBlowBys,
            editable: editable ?? true,
            value: object?.nonMotorizedBlowBys,
            width: .Forth
        )
        sectionItems.append(nonMotorizedBlowBys)
        
        let shitEndComments = TextAreaInput(
            key: "shitEndComments",
            header: ShiftFormHeaders.ShiftEnd.comments,
            editable: editable ?? true,
            value: object?.shitEndComments ?? "",
            width: .Full
        )
        sectionItems.append(shitEndComments)
        
        return sectionItems
    }
    
    
}
