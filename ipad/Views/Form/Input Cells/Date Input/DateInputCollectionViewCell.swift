//
//  DateInputCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-01.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class DateInputCollectionViewCell: BaseInputCell<DateInput>, UITextFieldDelegate {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false;
    }
    
    // MARK: Setup
    override func initialize(with model: DateInput) {
        self.headerLabel.text = model.header
        textFieldText()
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.onClick))
        self.textField.addGestureRecognizer(gesture)
    }
    
    @objc func onClick(sender: UITapGestureRecognizer) {
        guard let model = self.model, let delegate = self.inputDelegate else { return }
        if model.editable {
            delegate.showDatepickerDelegate(on: textField, initialDate: model.getValue() ?? nil, minDate: nil, maxDate: Date()) { (selectedDate) in
                if let selectedDate = selectedDate {
                    if selectedDate < Date(timeIntervalSinceNow: 600) {
                        model.setValue(value: selectedDate)
                    } else {
                        model.setValue(value: Date())
                    }
                    self.textFieldText()
                    self.emitChange()
                }
            }
        }
    }

    
    private func textFieldText() {
        if let model = self.model, let value: Date = model.value.get(type: model.type) as? Date  {
            self.textField.text = value.string()
        }
    }
    
    // MARK: Style
    override func style() {
        styleInput(field: textField, header: headerLabel, editable: model?.editable ?? false)
    }
    
}
