//
//  Options.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-29.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import UIKit

class Options {
    private lazy var optionsVC: OptionsViewController = {
        return UIStoryboard(name: "Options", bundle: Bundle.main).instantiateViewController(withIdentifier: "Options") as! OptionsViewController
    }()
    
    public func getVC() -> OptionsViewController {
        return optionsVC
    }
}
