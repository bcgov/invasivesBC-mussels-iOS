//
//  DropdownCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-31.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class DropdownCollectionViewCell: BaseInputCell<DropdownInput>, UITextFieldDelegate {
    
    let arrowIconName = "arrowtriangle.down.circle.fill"
    let clearIconName = "xmark.circle.fill"
    
    // MARK: Outlets
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var actionButton: UIButton!
    
    // MARK: Variables
    
    // MARK: Class functions
    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false;
    }
    
    // MARK: Outlet Actions
    @IBAction func actionButtonPressed(_ sender: Any) {
         guard let model = self.model, let value = model.getValue() else {return}
        if value.isEmpty {
            showOptions()
        } else {
            clearValue()
        }
    }
    
    // MARK: Setup
    override func initialize(with model: DropdownInput) {
        self.headerLabel.text = model.header
        self.textField.accessibilityLabel = model.header.lowercased()
        self.textField.accessibilityValue = model.header.lowercased()
        
        textField.text = nil

        if let currentValue = model.value.get(type: .Dropdown) as? String {
            for item in model.dropdownItems where item.key == currentValue {
                self.textField.text = item.key
            }
        }
        
        textField.delegate = self
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.onClick))
        self.textField.addGestureRecognizer(gesture)
        style()
        setIcon()
    }
    
    @objc func onClick(sender : UITapGestureRecognizer) {
        showOptions()
    }
    
    func showOptions() {
        guard let model = self.model, let delegate = self.inputDelegate else {return}
        if model.editable {
            delegate.showDropdownDelegate(items: model.dropdownItems, on: textField) { [weak self] (selectedItem) in
                guard let _self = self else {return}
                guard let selectedItem = selectedItem else {return}
                model.value.set(value: selectedItem.key, type: .Dropdown)
                _self.setCurrentField(value: selectedItem.key)
                _self.emitChange()
            }
        }
    }
    
    func clearValue() {
        guard let model = self.model, model.editable else {return}
        model.value.set(value: "", type: .Dropdown)
        self.textField.text = ""
        emitChange()
        setIcon()
    }
    
    override func updateValue(value: InputValue) {
        guard let model = self.model, let newValue =  value.get(type: .Dropdown) as? String else {return}
        for item in model.dropdownItems where item.key ==  newValue{
            self.textField.text = item.key
        }
        setIcon()
    }
    
    func setCurrentField(value key: String) {
        guard let model = self.model else {return}
        for item in model.dropdownItems where item.key == key {
            self.textField.text = item.key
            setIcon()
            break;
        }
    }
    
    // MARK: Style
    override func style() {
        styleInput(field: textField, header: headerLabel, editable: model?.editable ?? false)
    }
    
    func setIcon() {
        guard let model = self.model, let value = model.getValue() else {return}
        actionButton.alpha = model.editable ? 1 : 0
        if value.isEmpty {
            actionButton.setImage(UIImage(systemName: arrowIconName), for: .normal)
        } else {
            actionButton.setImage(UIImage(systemName: clearIconName), for: .normal)
        }
    }
    
}
