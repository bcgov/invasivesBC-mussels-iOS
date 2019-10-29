//
//  Theme.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-28.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import UIKit
import Extended

protocol Theme {}
extension Theme {
    
    // MARK: Fonts
    func getSubHeaderFont() -> UIFont {
        return Fonts.getPrimaryBold(size: 17)
    }
    
    func getInputFieldFont() -> UIFont {
        return Fonts.getPrimary(size: 15)
    }
    
    // MARK: Label Text
    // App Title
    func setAppTitle(label: UILabel, darkBackground: Bool? = false) {
        label.text = StringConstants.appTitle
        styleAppTitle(label: label, darkBackground: darkBackground ?? false)
    }
    
    func styleAppTitle(label: UILabel, darkBackground:Bool? = false) {
        label.textColor = darkBackground ?? false ? UIColor.white : Colors.primary
        label.font = Fonts.getPrimaryBold(size: 30)
    }
    
    // Body
    func styleBody(label: UILabel, darkBackground: Bool? = false) {
        label.textColor = darkBackground ?? false ? UIColor.white : Colors.bodyText
        label.font = Fonts.getPrimary(size: 15)
    }
    
    // Sub-header
    func styleSubHeader(label: UILabel, darkBackground: Bool? = false) {
          label.textColor = darkBackground ?? false ? UIColor.white : Colors.bodyText
          label.font = getSubHeaderFont()
          label.change(kernValue: -0.52)
          label.adjustsFontSizeToFitWidth = true
    }
    
    func styleFieldHeader(label: UILabel) {
        label.textColor = Colors.inputHeaderText
        label.font = Fonts.getPrimaryBold(size: 12)
        label.adjustsFontSizeToFitWidth = true
    }
    
    func styleFieldInput(textField: UITextField) {
        textField.textColor = Colors.inputText
        textField.backgroundColor = Colors.inputBackground
        textField.font = getInputFieldFont()
        textField.layer.cornerRadius = 3
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = Colors.inputBackground.cgColor
    }
    
    // MARK: Buttons
    // MARK: Buttons
    func styleHollowButton(button: UIButton) {
        styleButton(button: button, bg: UIColor.white, borderColor: Colors.primary.cgColor, titleColor:Colors.primary)
    }

    func styleFillButton(button: UIButton) {
        styleButton(button: button, bg: Colors.primary, borderColor: Colors.primary.cgColor, titleColor: UIColor.white)
        if let label = button.titleLabel {
            label.font = Fonts.getPrimary(size: 17)
        }
    }

    func styleButton(button: UIButton, bg: UIColor, borderColor: CGColor, titleColor: UIColor) {
           button.layer.cornerRadius = 5
           button.backgroundColor = bg
           button.layer.borderWidth = 1
           button.layer.borderColor = borderColor
           button.setTitleColor(titleColor, for: .normal)
    }
    
    // MARK: Colors
    // Style a garadiant nav bar
    func setGradiantNavBar(view: UIView) {
        setGradientBackground(view: view, colorOne: UIColor(hex: "#0053A4"), colorTwo: UIColor(hex:"#002C71"));
    }
    
    // Set grediant branckground
    func setGradientBackground(view: UIView, colorOne: UIColor, colorTwo: UIColor) {
        view.insertHorizontalGradient(colorTwo, colorOne)
    }
    
    public func addShadow(to layer: CALayer, opacity: Float, height: Int, radius: CGFloat? = 10) {
        layer.borderColor = UIColor(red:0.14, green:0.25, blue:0.46, alpha:0.2).cgColor
        layer.shadowOffset = CGSize(width: 0, height: height)
        layer.shadowColor = UIColor(red:0.14, green:0.25, blue:0.46, alpha:0.2).cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = 10
    }
    
    // MARK: Circle
    // Circular view
    func makeCircle(view: UIView) {
        view.layer.cornerRadius = view.frame.size.height/2
    }

    // Circular button
    func makeCircle(button: UIButton) {
        makeCircle(layer: button.layer, height: button.bounds.height)
    }

    // Circular layer
    func makeCircle(layer: CALayer, height: CGFloat) {
        layer.cornerRadius = height/2
    }
    
    // MARK: Contraints
    // Add Contraints to view to equal another
    func addEqualSizeContraints(to toView: UIView, from fromView: UIView) {
        toView.translatesAutoresizingMaskIntoConstraints = false
        toView.heightAnchor.constraint(equalTo: fromView.heightAnchor, constant: 0).isActive = true
        toView.widthAnchor.constraint(equalTo: fromView.widthAnchor, constant: 0).isActive = true
        toView.leadingAnchor.constraint(equalTo: fromView.leadingAnchor, constant: 0).isActive = true
        toView.trailingAnchor.constraint(equalTo: fromView.trailingAnchor, constant: 0).isActive = true
    }
    
    // Mark: View & Layer
    func roundCorners(layer: CALayer) {
        layer.cornerRadius = 8
    }
}
