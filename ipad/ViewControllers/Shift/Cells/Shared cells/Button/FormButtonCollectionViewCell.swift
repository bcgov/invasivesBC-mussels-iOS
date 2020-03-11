//
//  ButtonCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-05.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class FormButtonCollectionViewCell: UICollectionViewCell, Theme {
    
    typealias FormButtonCompletion = (_ action: FormButtonAction,_ info: Bool?) -> Void

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var dryStorageSwitch: UISwitch?
    @IBOutlet weak var switchLabel: UILabel?
    @IBOutlet weak var unknownWaterBodySwitchLabel: UILabel?
    @IBOutlet weak var unknownWaterBodySwitch: UISwitch?
    
    struct Config {
        var status: Bool = false
        var unknownWaterBodyStatus: Bool = false
        var isPreviousJourney: Bool = false
        var displaySwitch: Bool = false
        var displayUnknowSwitch: Bool = false
    }
    
    enum FormButtonAction {
        case add, dryStorage, unknownWaterBody
    }
    
    
    var completion: FormButtonCompletion?
    @objc weak var target: NSObject?
    @objc var _selector: Selector?
    
    var disableButton: Bool {
        return (dryStorageSwitch?.isOn ?? false) || (unknownWaterBodySwitch?.isOn ?? false)
    }
    
    @IBAction func buttonAction(_ sender: UIButton) {
        // let _ = self.target?.perform(_selector, with: [:])
        guard let onClick = self.completion else {return}
        return onClick(.add, nil)
    }
    
    @IBAction func dryStorageSwitchAction(_ sender: UISwitch?) {
        guard let onClick = self.completion else {return}
        guard let switchObj: UISwitch = sender else {return}
        self.set(status: disableButton)
        return onClick(.dryStorage, switchObj.isOn)
    }
    
    @IBAction func unknownSwitchAction(_ sender: UISwitch?) {
        guard let onClick = self.completion else {return}
        guard let switchObj: UISwitch = sender else {return}
        self.set(status: disableButton)
        return onClick(.unknownWaterBody, switchObj.isOn)
    }
    
    func set(status: Bool) {
        self.button?.isEnabled = !status
        if status {
            styleDisable(button: self.button)
        } else {
            styleHollowButton(button: button)
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
        
        if config.displaySwitch || config.displayUnknowSwitch {
            set(status: (config.status || config.unknownWaterBodyStatus))
        } else {
            set(status: true)
        }
    }
    
    func setup(with title: String, isEnabled: Bool, config: Config, target: NSObject, selectorButton: Selector, selectorSwitch: Selector) {
        self.button.setTitle(title, for: .normal)
        self.setupConfig(config: config)
        self.button.addTarget(target, action: selectorButton, for: .touchUpInside)
        self.dryStorageSwitch?.addTarget(target, action: selectorSwitch, for: .valueChanged)
        if !isEnabled {
            self.button.isEnabled = false
            self.dryStorageSwitch?.isEnabled = false
            self.alpha = 0
        }
    }
    
    func setup(with title: String, isEnabled: Bool, config: Config, onClick: @escaping FormButtonCompletion) {
        self.button.setTitle(title, for: .normal)
        self.setupConfig(config: config)
        self.completion = onClick
        if !isEnabled {
            self.button.isEnabled = false
            self.alpha = 0
        }
    }
    
    func style() {
        styleHollowButton(button: button)
    }

}
