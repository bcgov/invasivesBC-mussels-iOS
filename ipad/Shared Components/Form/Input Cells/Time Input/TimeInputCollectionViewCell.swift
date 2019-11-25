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
        textFieldText()
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.onClick))
        self.textField.addGestureRecognizer(gesture)
        style()
    }
    
    @objc func onClick(sender : UITapGestureRecognizer) {
        guard let model = self.model, let delegate = self.inputDelegate else {return}
        if model.editable {
            delegate.showDatepickerDelegate(on: textField, initialDate: model.value.get(type: .Date) as? Date ?? nil, minDate: nil, maxDate: nil) { (selectedDate) in
                model.value.set(value: selectedDate, type: .Date)
                self.textFieldText()
                self.emitChange()
            }
        }
    }
    
    private func textFieldText() {
        if let model = self.model, let value: Date = model.value.get(type: model.type) as? Date  {
            self.textField.text = value.string()
        }
    }
    
    // MARK: Style
    private func style() {
        styleFieldHeader(label: headerLabel)
        styleFieldInput(textField: textField)
    }
    
}
