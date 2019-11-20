//
//  StringExtension.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-07.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation

extension String {
    func occurrences(of char: Character) -> Int {
        return self.filter { $0 == char }.count
    }
}
