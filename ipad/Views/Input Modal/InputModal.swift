//
//  InputModal.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-29.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit
import Modal
import IQKeyboardManagerSwift

enum InputModalType {
    case String
    case Double
    case Integer
    case Year
}

class InputModal: ModalView, Theme {
    
    // MARK: Variables
    var header: String = ""
    var taken: [String] = [String]()
    var callBack: ((_ value: String) -> Void )?
    var acceptedPopupInput: InputModalType = .String
    
    // MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var input: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var inputHeight: NSLayoutConstraint!
    
    
    // MARK: Outlet Actions
    @IBAction func cancelAction(_ sender: UIButton) {
        if let callback = self.callBack {
            callback("")
            remove()
        }
    }
    
    @IBAction func addAction(_ sender: UIButton) {
        if let callback = self.callBack, let text = input.text, validateInput(text: text) {
            callback(text)
            remove()
        }
    }
    
    @IBAction func inputChanged(_ sender: UITextField) {
        if let text = sender.text, validateInput(text: text) {
            return
        }
    }
    
    // MARK: Validations
    func invalidInput(message: String) {
        titleLabel.text = message
        titleLabel.textColor = Colors.warn
    }
    
    func validInput() {
        titleLabel.text = header
        styleFieldHeader(label: titleLabel)
    }
    
    func validateInput(text: String) -> Bool {
        if text.removeWhitespaces().isEmpty {
            invalidInput(message: "Please enter a value")
            return false
        } else {
            // value is not duplicate
            if taken.contains(text) {
                invalidInput(message: "Duplicate value")
                return false
            } else {
                // value is in correct format
                switch acceptedPopupInput {
                case .String:
                    validInput()
                    return true
                case .Double:
                    if text.isDouble {
                        validInput()
                        return true
                    } else {
                        invalidInput(message: "Invalid value")
                        return false
                    }
                case .Integer:
                    if text.isInt {
                        validInput()
                        return true
                    } else {
                        invalidInput(message: "Invalid value")
                        return false
                    }
                case .Year:
                    if text.isInt {
                        let year = Int(text) ?? 0
                        if (year > 2000) && (year < 2100) {
                            validInput()
                            return true
                        } else {
                            invalidInput(message: "Invalid Year")
                            return false
                        }
                    } else {
                        invalidInput(message: "Invalid value")
                        return false
                    }
                }
            }
        }
    }
    
    // MARK: Entry Point
    func initialize(header: String, taken: [String]? = [String](), completion: @escaping (_ value: String) -> Void) {
        if let taken = taken {
            self.taken = taken
        }
        self.header = header
        self.callBack = completion
        setFixed(width: 350, height: 160)
        style()
        present()
        autoFill()
        DispatchQueue.main.asyncAfter(deadline: .now() + (SettingsConstants.animationDuration + 0.1)) {
            self.layoutIfNeeded()
            IQKeyboardManager.shared.keyboardDistance = self.getDistanceFromField()
            self.input.becomeFirstResponder()
        }
    }
    
    // MARK: Setup
    func getDistanceFromField() -> CGFloat {
        let total = self.frame.height
        
        // 15 and 8 are title lable's top and bottom constraints
        return total - (inputHeight.constant + titleLabel.frame.height + 15 + 8)
    }
    
    func autoFill() {
        self.titleLabel.text = header
    }
    
    // MARK: Style
    func style() {
        styleInput(field: input, header: titleLabel, editable: true)
        styleHollowButton(button: cancelButton)
        styleFillButton(button: addButton)
        self.backgroundColor = UIColor.white
        roundCorners(layer: self.layer)
        addShadow(to: self.layer, opacity: 0.8, height: 2)
    }
}
