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
    
    let charLimit = 300
    
    // MARK: Delegate functions
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newValue = (textView.text as NSString).replacingCharacters(in: range, with: text)
        if newValue.count <= textView.text.count {return true}
        return newValue.count <= charLimit
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard let model = self.model else {return}
        if model.value.get(type: model.type) as? String != textView.text {
            model.value.set(value: textView.text ?? "", type: model.type)
            self.emitChange()
            style()
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
        textArea.isScrollEnabled = true
        
        if let m = model, let value = m.value.get(type: .TextArea) as? String, value.count > charLimit {
            textArea.backgroundColor = Colors.warn.withAlphaComponent(0.3)
        }
    }
    
    
}
