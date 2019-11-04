//
//  Dropdown.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-29.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import UIKit

class Dropdown {
    lazy var dropdownVC: DropdownViewController = {
        return UIStoryboard(name: "Dropdown", bundle: Bundle.main).instantiateViewController(withIdentifier: "Dropdown") as! DropdownViewController
    }()
    
    public func getVC() -> DropdownViewController {
        return dropdownVC
    }
}
