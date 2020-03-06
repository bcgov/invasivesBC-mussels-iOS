//
//  ButtonCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-05.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class FormButtonCollectionViewCell: UICollectionViewCell, Theme {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var dryStorageSwitch: UISwitch?
    @IBOutlet weak var switchLabel: UILabel?
    
    struct Config {
        var status: Bool = false
        var isPreviousJourney: Bool = false
        var displaySwitch: Bool = false
    }
    
    
    var completion: (()-> Void)?
    @objc weak var target: NSObject?
    @objc var _selector: Selector?
    
    @IBAction func buttonAction(_ sender: UIButton) {
        let _ = self.target?.perform(_selector, with: [:])
        guard let onClick = self.completion else {return}
        return onClick()
    }
    
    func set(status: Bool) {
        self.button?.isEnabled = !status
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
        
        if config.displaySwitch {
            set(status: config.status)
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
        style()
    }
    
    func setup(with title: String, isEnabled: Bool, config: Config, onClick: @escaping ()-> Void) {
        self.button.setTitle(title, for: .normal)
        self.setupConfig(config: config)
        self.completion = onClick
        if !isEnabled {
            self.button.isEnabled = false
            self.alpha = 0
        }
        style()
    }
    
    func style() {
        styleHollowButton(button: button)
    }

}
