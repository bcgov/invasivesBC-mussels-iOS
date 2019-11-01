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
    }
    
    // MARK: Setup
    override func initialize(with model: TextInput) {
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
