//
//  WaterbodyPickerViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2020-06-30.
//  Copyright © 2020 Amir Shayegh. All rights reserved.
//

import UIKit

class WaterbodyPickerViewController: BaseViewController {
    
    var model: WatercradftInspectionModel? = nil
    var pickerVC: WaterbodyPicker? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addPicker()
        
    }
    
    func addPicker() {
        if let picker = pickerVC {
            picker.removeFromSuperview()
            pickerVC = nil
        }
        guard let model = model else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        let waterBodyPicker: WaterbodyPicker = UIView.fromNib()
        self.pickerVC = waterBodyPicker
        waterBodyPicker.setup(in: self) { [weak self] (result) in
            guard let strongerSelf = self else {return}
            for waterBody in result {
                model.addPreviousWaterBody(model: waterBody)
            }
            waterBodyPicker.removeFromSuperview()
            strongerSelf.dismiss(animated: true, completion: nil)
        }
    }
    
    
}
