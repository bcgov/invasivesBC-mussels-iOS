//
//  TimeInputCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-25.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class TimeInputCollectionViewCell:  BaseInputCell<TimeInput>, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var headerLabel: UILabel!
    // MARK: UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false;
    }
    
    // MARK: Setup
    override func initialize(with model: TimeInput) {
        self.headerLabel.text = model.header
        self.textField.accessibilityLabel = model.header.removeWhitespaces().lowercased()
        self.textField.accessibilityValue = model.header.removeWhitespaces().lowercased()
        setTextFieldText()
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.onClick))
        self.textField.addGestureRecognizer(gesture)
        style()
    }
    
    @objc func onClick(sender : UITapGestureRecognizer) {
        guard let model = self.model, let delegate = self.inputDelegate else {return}
        if model.editable {
            delegate.showTimePickerDelegate(on: textField, initialTime: model.getValue()) { (selectedTime) in
                model.setValue(value: selectedTime)
                self.setTextFieldText()
                self.emitChange()
            }
        }
    }
    
    private func setTextFieldText() {
        if let model = self.model, let value: Time = model.getValue()  {
            self.textField.text = value.toString()
        }
    }
    
    // MARK: Style
    override func style() {
        styleInput(field: textField, header: headerLabel, editable: model?.editable ?? false)
    }
    
}
