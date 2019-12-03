//
//  ArrayExtension.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-12-02.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
extension Array where Element: Hashable {
    var uniques: Array {
        var buffer = Array()
        var added = Set<Element>()
        for elem in self {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
}
