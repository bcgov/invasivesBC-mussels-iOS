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
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.onClick))
        self.textField.addGestureRecognizer(gesture)
    }
    
    @objc func onClick(sender : UITapGestureRecognizer) {
        guard let model = self.model, let delegate = self.inputDelegate else {return}
        if model.editable {
            delegate.showDatepickerDelegate(on: textField, initialDate: model.value.get(type: .Date) as? Date ?? nil, minDate: nil, maxDate: nil) { (selectedDate) in
                model.value.set(value: selectedDate, type: .Date)
            }
        }
    }
    
    // MARK: Style
    private func style() {
        styleFieldHeader(label: headerLabel)
        
    }
    
}
