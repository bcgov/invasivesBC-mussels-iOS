//
//  Theme.swift
//  ipad
//
//  Created by Amir Shayegh on 2020-04-03.
//  Copyright © 2020 Amir Shayegh. All rights reserved.
//

import Foundation
import UIKit

extension Theme {
    
    // MARK: Colors
    // Gradiant UIView
    public func setGradiantBackground(view: UIView) {
        setGradientBackground(view: view, colorOne: UIColor(hex: "#0053A4"), colorTwo: UIColor(hex:"#002C71"));
    }
    
    // Gradiant Navbar
    public func setGradiantBackground(navigationBar: UINavigationBar) {
        setGradiantBackground(navigationBar: navigationBar, colorOne: UIColor(hex:"#002C71"), colorTwo: UIColor(hex: "#0053A4"))
    }
    
    // MARK: Fonts
    public func getSubHeaderFont() -> UIFont {
        return Fonts.getPrimaryBold(size: 17)
    }
    
    public func getInputFieldFont() -> UIFont {
        return Fonts.getPrimary(size: 15)
    }
    
    public func getSwitcherFont() -> UIFont {
        return Fonts.getPrimaryBold(size: 17)
    }
    
    // MARK: Label Text
    // App Title
    public func setAppTitle(label: UILabel, darkBackground: Bool? = false) {
        label.text = StringConstants.appTitle
        styleAppTitle(label: label, darkBackground: darkBackground ?? false)
    }
    
    public func styleAppTitle(label: UILabel, darkBackground:Bool? = false) {
        label.textColor = darkBackground ?? false ? UIColor.white : Colors.primary
        label.font = Fonts.getPrimaryBold(size: 30)
    }
    
    // Body
    public func styleBody(label: UILabel, darkBackground: Bool? = false) {
        label.textColor = darkBackground ?? false ? UIColor.white : Colors.bodyText
        label.font = Fonts.getPrimary(size: 15)
    }
    
    // Sub-header
    public func styleSubHeader(label: UILabel, darkBackground: Bool? = false) {
        label.textColor = darkBackground ?? false ? UIColor.white : Colors.bodyText
        label.font = getSubHeaderFont()
        label.change(kernValue: -0.52)
        label.adjustsFontSizeToFitWidth = true
    }
    
    // Input field header
    public func styleFieldHeader(label: UILabel) {
        label.textColor = Colors.inputHeaderText
        label.font = Fonts.getPrimaryBold(size: 14)
        label.adjustsFontSizeToFitWidth = true
    }
    
    // Input field content
    private func styleFieldInput(textField: UITextField) {
        textField.textColor = Colors.inputText
        textField.backgroundColor = Colors.inputBackground
        textField.font = getInputFieldFont()
        textField.layer.cornerRadius = 3
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = Colors.inputBackground.cgColor
    }
    
    private func styleFieldInputReadOnly(textField: UITextField) {
        textField.textColor = Colors.inputText
        textField.backgroundColor = .clear
        textField.font = getInputFieldFont()
        textField.layer.cornerRadius = 0
        textField.borderStyle = .none
        textField.layer.borderColor = UIColor.clear.cgColor
    }
    
    public func styleInput(field: UITextField, header: UILabel, editable: Bool) {
        if editable {
            styleFieldInput(textField: field)
            styleFieldHeader(label: header)
        } else {
            styleFieldHeader(label: header)
            styleFieldInputReadOnly(textField: field)
        }
        
    }
    
    // Input field content
    public func styleFieldInput(textField: UITextView) {
        textField.textColor = Colors.inputText
        textField.backgroundColor = Colors.inputBackground
        textField.font = getInputFieldFont()
        textField.layer.cornerRadius = 3
        textField.layer.borderColor = Colors.inputBackground.cgColor
    }
    
    // Form Section title
    public func styleSectionTitle(label: UILabel) {
        label.textColor = Colors.primary
        label.font = Fonts.getPrimaryBold(size: 22)
    }
    
    // MARK: Buttons
    public func styleHollowButton(button: UIButton) {
        styleButton(button: button, bg: UIColor.white, borderColor: Colors.primary.cgColor, titleColor:Colors.primary)
        button.tintColor = Colors.primary
    }
    
    public func styleDisable(button: UIButton) {
        styleButton(button: button, bg: UIColor.white, borderColor: UIColor.gray.cgColor, titleColor: UIColor.gray)
    }
    
    public func styleFillButton(button: UIButton) {
        styleButton(button: button, bg: Colors.primary, borderColor: Colors.primary.cgColor, titleColor: UIColor.white)
        if let label = button.titleLabel {
            label.font = Fonts.getPrimary(size: 17)
        }
    }
    
    private func styleButton(button: UIButton, bg: UIColor, borderColor: CGColor, titleColor: UIColor) {
        button.layer.cornerRadius = 5
        button.backgroundColor = bg
        button.layer.borderWidth = 1
        button.layer.borderColor = borderColor
        button.setTitleColor(titleColor, for: .normal)
    }
    
    // MARK: View & Layer
    public func roundCorners(layer: CALayer) {
        layer.cornerRadius = 8
    }
    
    public func styleCard(layer: CALayer) {
        roundCorners(layer: layer)
        addShadow(to: layer, opacity: 08, height: 2)
    }
    
    public func styleDivider(view: UIView) {
        view.backgroundColor = Colors.secondary
    }
    public func styleDividerGrey(view: UIView) {
        view.backgroundColor = Colors.Status.LightGray
    }
}
