//
//  DropdownModel.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-29.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation

class DropdownModel {
    var display: String = ""
    var key: String = ""

    init(display: String, key: String? = nil) {
        if let v = key {
            self.key = v
        } else {
            self.key = display
        }
        self.display = display
    }
}
