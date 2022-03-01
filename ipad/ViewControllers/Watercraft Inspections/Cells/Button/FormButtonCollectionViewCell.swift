//
//  ButtonCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-05.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class FormButtonCollectionViewCell: UICollectionViewCell, Theme {
    
    typealias FormButtonCompletion = (_ action: FormButtonAction) -> Void

    // MARK: Outlets
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var majorCityButton: UIButton!;
    @IBOutlet weak var dryStorageSwitch: UISwitch?
    @IBOutlet weak var switchLabel: UILabel?
    @IBOutlet weak var unknownWaterBodySwitchLabel: UILabel?
    @IBOutlet weak var unknownWaterBodySwitch: UISwitch?
    @IBOutlet weak var commercialManufacturerSwitch: UISwitch?
    
    struct Config {
        var status: Bool = false
        var majorCityStatus: Bool = false;
        var unknownWaterBodyStatus: Bool = false
        var commercialManufacturerStatus: Bool = false
        var isPreviousJourney: Bool = false
        var displaySwitch: Bool = false
        var displayUnknowSwitch: Bool = false
    }
    

    struct Result {
        var dryStorage: Bool = false
        var unknown: Bool = false
        var commercialManufacturer: Bool
    }
    
    enum FormButtonAction {
        case add, addMajorCity, statusChange(Result)
    }
    
    
    var completion: FormButtonCompletion?
    @objc weak var target: NSObject?
    @objc var _selector: Selector?
    
    var disableButton: Bool {
        return (dryStorageSwitch?.isOn ?? false) || (unknownWaterBodySwitch?.isOn ?? false) || (commercialManufacturerSwitch?.isOn ?? false)
    }
    
    var disableMajorCityButton: Bool {
        if (dryStorageSwitch?.isOn ?? true) {
            return false
        } else if (unknownWaterBodySwitch?.isOn ?? true) {
            return false
        } else if (commercialManufacturerSwitch?.isOn ?? true) {
            return false
        } else {
            return true
        }
    }
    
    var result: Result {
        return Result(dryStorage: (dryStorageSwitch?.isOn ?? false),
                      unknown: unknownWaterBodySwitch?.isOn ?? false,
                      commercialManufacturer: commercialManufacturerSwitch?.isOn ?? false)
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        // let _ = self.target?.perform(_selector, with: [:])
        guard let onClick = self.completion else {return}
        return onClick(.add)
    }
    
    @IBAction func majorCityButtonAction(_ sender: UIButton) {
        // let _ = self.target?.perform(_selector, with: [:])
        guard let onClick = self.completion else {return}
        return onClick(.addMajorCity)
    }
    
    @IBAction func dryStorageSwitchAction(_ sender: UISwitch?) {
        guard let onClick = self.completion else {return}
        guard let switchObj: UISwitch = sender else {return}
        self.set(status: disableButton)
        self.set(status: disableMajorCityButton)
        if switchObj.isOn {
            self.unknownWaterBodySwitch?.isOn = false
            self.commercialManufacturerSwitch?.isOn = false
        }
        return onClick(.statusChange(self.result))
    }
    
    @IBAction func unknownSwitchAction(_ sender: UISwitch?) {
        guard let onClick = self.completion else {return}
        guard let switchObj: UISwitch = sender else {return}
        self.set(status: disableButton)
        self.set(status: disableMajorCityButton)
        if switchObj.isOn {
            self.dryStorageSwitch?.isOn = false
            self.commercialManufacturerSwitch?.isOn = false
        }
        return onClick(.statusChange(self.result))
    }
    
    @IBAction func commercialManufacturerSwitchAction(_ sender: UISwitch?) {
        guard let onClick = self.completion else {return}
        guard let switchObj: UISwitch = sender else {return}
        self.set(status: disableButton)
        self.set(status: disableMajorCityButton)
        if switchObj.isOn {
            self.dryStorageSwitch?.isOn = false
            self.unknownWaterBodySwitch?.isOn = false
        }
        return onClick(.statusChange(self.result))
    }
    
    func set(status: Bool) {
        self.button?.isEnabled = !status
        self.majorCityButton?.isEnabled = status;
        if status {
            styleDisable(button: self.button)
            styleHollowButton(button: self.majorCityButton)
        } else {
            styleHollowButton(button: button)
            styleDisable(button: majorCityButton)
        }
    }
    
    private func setupConfig(config: Config) {
        self.dryStorageSwitch?.isHidden = !config.displaySwitch
        self.switchLabel?.isHidden = !config.displaySwitch
        self.dryStorageSwitch?.isOn = config.status
        if config.isPreviousJourney {
            self.switchLabel?.text = "Previously Stored"
        } else {
            self.switchLabel?.text = "Being Stored"
        }
        self.unknownWaterBodySwitch?.isHidden = !config.displayUnknowSwitch
        self.unknownWaterBodySwitch?.isOn = config.unknownWaterBodyStatus
        
        self.commercialManufacturerSwitch?.isOn = config.commercialManufacturerStatus
        
        if config.displaySwitch || config.displayUnknowSwitch {
            set(status: (config.status || config.unknownWaterBodyStatus || config.commercialManufacturerStatus))
        } else {
            set(status: true)
        }
    }
    
    func setup(with title: String, isEnabled: Bool, config: Config, target: NSObject, cityTarget: NSObject, selectorButton: Selector, selectorCityButton: Selector, selectorSwitch: Selector) {
        self.button.setTitle(title, for: .normal)
        self.majorCityButton.setTitle("Add Closest Major City", for: .normal)
        self.setupConfig(config: config)
        self.majorCityButton.addTarget(cityTarget, action: selectorCityButton, for: .touchUpInside)
        self.button.addTarget(target, action: selectorButton, for: .touchUpInside)
        self.dryStorageSwitch?.addTarget(target, action: selectorSwitch, for: .valueChanged)
        if !isEnabled {
            self.majorCityButton.isEnabled = false;
            self.button.isEnabled = false
            self.dryStorageSwitch?.isEnabled = false
            self.alpha = 0
        }
    }
    
    func setup(with title: String, isEnabled: Bool, config: Config, onClick: @escaping FormButtonCompletion) {
        self.button.setTitle(title, for: .normal)
        self.majorCityButton.setTitle("Add Closest Major City", for: .normal)
        self.setupConfig(config: config)
        self.completion = onClick
        if !isEnabled {
            self.majorCityButton.isEnabled = false;
            self.button.isEnabled = false
            self.alpha = 0
            self.unknownWaterBodySwitch?.isEnabled = false
            self.commercialManufacturerSwitch?.isEnabled = false
            self.dryStorageSwitch?.isEnabled = false
        }
    }
    
    func style() {
        styleHollowButton(button: button)
        styleHollowButton(button: majorCityButton)

    }

}
