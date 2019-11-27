//
//  TimePicker.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-25.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import UIKit

public class TimePicker {
    
    
    // Picker view controller
    private lazy var vc: TimePickerViewController = {
        return UIStoryboard(name: "TimePicker", bundle: nil).instantiateViewController(withIdentifier: "TimePicker") as! TimePickerViewController
    }()
    
    // MARK: Optionals
    
    
    // MARK: Setup
    public func setup(beginWith: Time? = nil, onChange: @escaping(_ time: Time?) -> Void) -> TimePickerViewController {
        vc.setup(initial: beginWith, onChange: onChange)
        return vc
    }
}
