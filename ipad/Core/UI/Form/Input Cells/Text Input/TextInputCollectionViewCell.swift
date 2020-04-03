//
//  TextInputCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-01.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit


class TextInputCollectionViewCell: BaseInputCell<TextInput>, UITextFieldDelegate {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }
    
    // MARK: UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let model = self.model else {return}
        model.value.set(value: textField.text ?? "", type: model.type)
        self.emitChange()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let model = self.model else {return false}
        if string.isEmpty {
            return true
        }
        switch model.validation {
        case .PassportNumber:
            if !string.isAlphanumeric {return false}
            if let text = textField.text,
               let textRange = Range(range, in: text) {
               let updatedText = text.replacingCharacters(in: textRange,
                                                           with: string)
               return validatePassport(text: updatedText)
            } else {
                return false
            }
        case .None:
            return true
        case .AlphaNumberic:
            return string.isAlphanumeric
        }
    }
    
    func validatePassport(text string: String) -> Bool {
        if !string.isAlphanumeric {return false}
        if !string.substring(toIndex: 2).isLetters { return false }
        if (string.count > 2 && Int(string.substring(fromIndex: 2)) == nil) { return false}
        if string.count > 8 {return false}
        return true
    }
    
    // MARK: Setup
    override func initialize(with model: TextInput) {
        self.headerLabel.text = model.header
        self.textField.text = model.value.get(type: model.type) as? String ?? ""
        textField.delegate = self
    }
    
    // MARK: Style
    private func style() {
        styleInput(field: textField, header: headerLabel, editable: model?.editable ?? false)
    }
    
}
