//
//  Notifications.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-29.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
extension Notification.Name {
    static let screenOrientationChanged = Notification.Name("screenOrientationChanged")
    static let InputItemValueChanged = Notification.Name("inputItemValueChanged")
    static let ShouldResizeInputGroup = Notification.Name("ShouldResizeInputGroup")
    static let InputFieldShouldUpdate = Notification.Name("InputFieldShouldUpdate")
    static let TableButtonClicked = Notification.Name("tableButtonClicked")
    static let syncExecuted = Notification.Name("syncExecuted")
    
    static let journeyItemValueChanged = Notification.Name("journeyItemValueChanged")
}
