//
//  IntegerStepperInputCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-25.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class IntegerStepperInputCollectionViewCell: BaseInputCell<IntegerStepperInput>, UITextFieldDelegate {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var stepper: UIStepper!
    
    @IBAction func stepperAction(_ sender: UIStepper) {
        guard let model = self.model else {return}
        let newValue = Int(sender.value)
        model.setValue(value: newValue)
        setValue(int: newValue)
        self.emitChange()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let model = self.model else {return}
        if let stringValue = textField.text, let number = Int(stringValue) {
            model.setValue(value: number)
        } else {
            model.setValue(value: 0)
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
    override func initialize(with model: IntegerStepperInput) {
        self.textField.keyboardType = .decimalPad
        self.headerLabel.text = model.header
        let current = model.getValue() ?? 0
        
        textField.delegate = self
        stepper.minimumValue = 0
        stepper.maximumValue = 10000
        setValue(int: current)
        style()
    }
    
    func setValue(int: Int) {
        self.textField.text = "\(int)"
        stepper.value = Double(int)
    }
    
    func style() {
        styleFieldInput(textField: textField)
        styleFieldHeader(label: headerLabel)
    }
}
