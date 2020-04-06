//
//  Theme.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-28.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import UIKit

protocol Theme {}
extension Theme {
    // MARK: Gradiant
    public func setGradientBackground(view: UIView, colorOne: UIColor, colorTwo: UIColor) {
        view.insertHorizontalGradient(colorTwo, colorOne)
    }
    
    public func setGradiantBackground(navigationBar: UINavigationBar, colorOne: UIColor, colorTwo: UIColor) {
        navigationBar.setGradientBackground(colors: [colorOne, colorTwo], startPoint: .bottomRight, endPoint: .bottomLeft)
    }
    
    // MARK: Shadow
    public func addShadow(to layer: CALayer, opacity: Float, height: Int, radius: CGFloat? = 10) {
        layer.borderColor = UIColor(red:0.14, green:0.25, blue:0.46, alpha:0.2).cgColor
        layer.shadowOffset = CGSize(width: 0, height: height)
        layer.shadowColor = UIColor(red:0.14, green:0.25, blue:0.46, alpha:0.2).cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = 10
    }
    
    // MARK: Circle
    // Circular view
    public func makeCircle(view: UIView) {
        view.layer.cornerRadius = view.frame.size.height/2
    }
    
    // Circular button
    public func makeCircle(button: UIButton) {
        makeCircle(layer: button.layer, height: button.bounds.height)
    }
    
    // Circular layer
    public func makeCircle(layer: CALayer, height: CGFloat) {
        layer.cornerRadius = height/2
    }
    
    // MARK: Contraints
    // Add Contraints to view to equal another
    public func addEqualSizeContraints(to toView: UIView, from fromView: UIView) {
        toView.translatesAutoresizingMaskIntoConstraints = false
        toView.heightAnchor.constraint(equalTo: fromView.heightAnchor, constant: 0).isActive = true
        toView.widthAnchor.constraint(equalTo: fromView.widthAnchor, constant: 0).isActive = true
        toView.leadingAnchor.constraint(equalTo: fromView.leadingAnchor, constant: 0).isActive = true
        toView.trailingAnchor.constraint(equalTo: fromView.trailingAnchor, constant: 0).isActive = true
    }
    
    // MARK: ANIMATIONS
    public func fadeLabelMessage(label: UILabel, tempText: String, delay: Double? = 3) {
        let defaultDelay: Double = 3
        let visibleAlpha: CGFloat = 1
        let invisibleAlpha: CGFloat = 0
        let originalText: String = label.text ?? ""
        let originalTextColor: UIColor = label.textColor
        // fade out current text
        UIView.animate(withDuration: SettingsConstants.shortAnimationDuration, animations: {
            label.alpha = invisibleAlpha
            label.layoutIfNeeded()
        }) { (done) in
            // change text
            label.text = tempText
            // fade in warning text
            UIView.animate(withDuration: SettingsConstants.shortAnimationDuration, animations: {
                label.textColor = Colors.accent.red
                label.alpha = visibleAlpha
                label.layoutIfNeeded()
            }, completion: { (done) in
                // revert after 3 seconds
                UIView.animate(withDuration: SettingsConstants.shortAnimationDuration, delay: delay ?? defaultDelay, animations: {
                    // fade out text
                    label.alpha = invisibleAlpha
                    label.layoutIfNeeded()
                }, completion: { (done) in
                    // change text
                    label.text = originalText
                    // fade in text
                    UIView.animate(withDuration: SettingsConstants.shortAnimationDuration, animations: {
                        label.textColor = originalTextColor
                        label.alpha = visibleAlpha
                        label.layoutIfNeeded()
                    })
                })
            })
        }
    }
}
