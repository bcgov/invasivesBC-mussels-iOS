//
//  DropdownCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-31.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class DropdownCollectionViewCell: BaseInputCell<DropdownInput>, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
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
    
    // MARK: Setup
    override func initialize(with model: DropdownInput) {
        self.headerLabel.text = model.header
        if let currentValue = model.value.get(type: .Dropdown) as? String {
            for item in model.dropdownItems where item.key == currentValue {
                self.textField.text = item.key
            }
        }
        textField.delegate = self
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.onClick))
        self.textField.addGestureRecognizer(gesture)
    }
    
    @objc func onClick(sender : UITapGestureRecognizer) {
        guard let model = self.model, let delegate = self.inputDelegate else {return}
        if model.editable {
            delegate.showDropdownDelegate(items: model.dropdownItems, on: textField) { (selectedItem) in
                guard let selectedItem = selectedItem else {return}
                model.value.set(value: selectedItem.key, type: .Dropdown)
                self.setCurrentField(value: selectedItem.key)
            }
        }
    }
    
    func setCurrentField(value key: String) {
        guard let model = self.model else {return}
        for item in model.dropdownItems where item.key == key {
            self.textField.text = item.key
            break;
        }
    }
    
    // MARK: Style
    private func style() {
        styleFieldInput(textField: textField)
        styleFieldHeader(label: headerLabel)
    }
    
}
