//
//  TextAreaInputCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-04.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class TextAreaInputCollectionViewCell: BaseInputCell<TextAreaInput>, UITextViewDelegate {
    
    // MARK: Delegate functions
    func textViewDidChange(_ textView: UITextView) {
        //        guard let model = self.model else {return}
        //        model.value.set(value: textView.text ?? "", type: model.type)
        //        self.emitChange()
    }
    
    // MARK: Setup
    override func initialize(with model: TextAreaInput) {
        //        self.headerLabel.text = model.header
        //        self.textArea.text = model.value.get(type: model.type) as? String ?? ""
        //        textArea.delegate = self
    }
    
    // MARK: Style
    private func style() {
        //        styleFieldInput(textField: textArea)
        //        styleFieldHeader(label: headerLabel)
    }
    
    
}
