//
//  NullSwitchInputCollectionViewCell.swift
//  ipad
//
//  Created by Claveau, David LWRS:EX on 2023-01-30.
//  Copyright © 2023 Amir Shayegh. All rights reserved.
//

import UIKit

class NullSwitchInputCollectionViewCell: BaseInputCell<NullSwitchInput> {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var nullSwitchView: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nullSwitchView.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        style()
    }

    @IBAction func switchDidChange(_ sender: UISegmentedControl) {
        guard let model = self.model else {return}
        
        switch sender.selectedSegmentIndex {
        case 0:// Switch is set to "No"
            nullSwitchView.selectedSegmentTintColor = .systemOrange
            model.value.set(value: false, type: model.type)
        case 1:// Switch is set to "Yes"
            nullSwitchView.selectedSegmentTintColor = .systemGreen
            model.value.set(value: true, type: model.type)
        default:// Switch is unset and remains "nil"
            model.value.set(value: nil, type: model.type)
        }
        
        model.interacted.set(value: true, type: model.validationName)
        self.emitChange()
    }
    
    // MARK: Setup
    override func initialize(with model: NullSwitchInput) {
        guard let model = self.model else {return}
        let value = model.getValue()
        
        switch value {
        case false:
            // First time loading the form, neither "Yes" or "No" are selected (null state)
            self.nullSwitchView.selectedSegmentIndex = UISegmentedControl.noSegment
            
            // If the button has been toggled before, then we show "No" as selected
            if model.interacted.get(type: model.validationName) ?? true {
                nullSwitchView.selectedSegmentTintColor = .systemOrange
                self.nullSwitchView.selectedSegmentIndex = 0
            }
        case true:
            nullSwitchView.selectedSegmentTintColor = .systemGreen
            self.nullSwitchView.selectedSegmentIndex = 1
        default:
            self.nullSwitchView.selectedSegmentIndex = UISegmentedControl.noSegment
        }
        
        self.headerLabel.text = model.header
        self.nullSwitchView?.accessibilityValue = model.header.removeWhitespaces().lowercased()
        self.nullSwitchView?.accessibilityLabel = model.header.removeWhitespaces().lowercased()
        self.accessibilityValue = "\(model.header.removeWhitespaces().lowercased())cell"
        self.accessibilityLabel = "\(model.header.removeWhitespaces().lowercased())cell"
    }
    
    // MARK: Style
    override func style() {
        styleFieldHeader(label: headerLabel)
    }
}
