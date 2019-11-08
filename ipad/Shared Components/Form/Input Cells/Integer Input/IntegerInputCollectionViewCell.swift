//
//  IntegerInputCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-07.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class IntegerInputCollectionViewCell: BaseInputCell<IntegerInput>, UITextFieldDelegate {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }
    
    // MARK: UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let model = self.model else {return}
        if let stringValue = textField.text, let number = Int(stringValue) {
            model.setValue(value: number)
        } else {
            model.setValue(value: nil)
        }
        self.emitChange()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let current = textField.text else {
            return false
        }
        let finalText = "\(current)\(string)"
        return Int(finalText) != nil
    }
    
    // MARK: Setup
    override func initialize(with model: IntegerInput) {
        self.textField.keyboardType = .decimalPad
        self.headerLabel.text = model.header
        self.textField.text = model.value.get(type: model.type) as? String ?? ""
        textField.delegate = self
    }
    
    func style() {
        styleFieldInput(textField: textField)
        styleFieldHeader(label: headerLabel)
    }
    
}
