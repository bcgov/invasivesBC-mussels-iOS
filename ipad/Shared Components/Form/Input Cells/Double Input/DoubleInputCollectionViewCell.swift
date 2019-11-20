//
//  DoubleInputCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-07.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class DoubleInputCollectionViewCell: BaseInputCell<DoubleInput>, UITextFieldDelegate {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }
    
    // MARK: UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let model = self.model else {return}
        if let stringValue = textField.text, let number = Double(stringValue) {
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
        if Double(finalText) != nil {
            return true
        } else {
            return finalText.first != "." && finalText.last == "." && finalText.occurrences(of: ".") == 1
        }
    }
    
    // MARK: Setup
    override func initialize(with model: DoubleInput) {
        self.textField.keyboardType = .decimalPad
        self.headerLabel.text = model.header
        self.textField.text = model.value.get(type: model.type) as? String ?? ""
        textField.delegate = self
    }
    
    // MARK: Style
    private func style() {
        styleFieldInput(textField: textField)
        styleFieldHeader(label: headerLabel)
    }
    
}
