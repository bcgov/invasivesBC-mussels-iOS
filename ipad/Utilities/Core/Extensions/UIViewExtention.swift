//
//  UIViewExtention.swift
//  ipad
//
//  Created by Amir Shayegh on 2020-04-03.
//  Copyright © 2020 Amir Shayegh. All rights reserved.
//

import Foundation
import UIKit
// MARK: Gradiant View
extension UIView {
    func insertHorizontalGradient(_ color1: UIColor, _ color2: UIColor) {
        let gradientView = GradientView(frame: bounds)
        gradientView.color1 = color1
        gradientView.color2 = color2
        gradientView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.insertSubview(gradientView, at: 0)
    }
}
