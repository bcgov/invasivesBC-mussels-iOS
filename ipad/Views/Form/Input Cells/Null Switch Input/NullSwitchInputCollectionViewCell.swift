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
                model.setValue(value: false)
            case 1:// Switch is set to "Yes"
                model.setValue(value: true)
            default:// Switch is unset and remains "nil"
                model.setValue(value: nil)
        }
        
        model.setInteracted()
        self.emitChange()
    }
    
    // MARK: Setup
    override func initialize(with model: NullSwitchInput) {
        guard let model = self.model else {return}
        
        switch model.getValue() {
            case false:// Switch is set to "No"
                if model.interacted {
                    self.nullSwitchView.selectedSegmentIndex = 0
                } else {
                    self.nullSwitchView.selectedSegmentIndex = UISegmentedControl.noSegment
                }
            case true:// Switch is set to "Yes"
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
