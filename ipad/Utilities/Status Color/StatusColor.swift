//
//  StatusColor.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-21.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import UIKit

class StatusColor {
    static func color(for status: String) -> UIColor {
        switch status {
        case "draft":
            return Colors.Status.LightGray
        case "pending":
            return Colors.Status.Yellow
        case "completed":
            return Colors.Status.Green
        default:
            return Colors.Status.LightGray
        }
    }
}
