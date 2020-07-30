//
//  TextAreaInputCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-04.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class TextAreaInputCollectionViewCell: BaseInputCell<TextAreaInput>, UITextViewDelegate {
    
    @IBOutlet weak var fieldHeader: UILabel!
    @IBOutlet weak var textArea: UITextView!
    
    // MARK: Delegate functions
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newValue = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newValue.count <= 500
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard let model = self.model else {return}
        if model.value.get(type: model.type) as? String != textView.text {
            model.value.set(value: textView.text ?? "", type: model.type)
            self.emitChange()
        }
    }
    
    // MARK: Setup
    override func initialize(with model: TextAreaInput) {
        self.fieldHeader.text = model.header
        self.textArea.text = model.value.get(type: model.type) as? String ?? ""
        textArea.delegate = self
        style()
    }
    
    // MARK: Style
    override func style() {
        styleFieldInput(textField: textArea)
        styleFieldHeader(label: fieldHeader)
    }
    
    
}
