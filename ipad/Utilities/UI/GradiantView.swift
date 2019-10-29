//
//  GradiantView.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-28.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func insertHorizontalGradient(_ color1: UIColor, _ color2: UIColor) {
        let gradientView = GradientView(frame: bounds)
        gradientView.color1 = color1
        gradientView.color2 = color2
        gradientView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.insertSubview(gradientView, at: 0)
    }
}

@IBDesignable
public class GradientView: UIView {
    private func createGradient() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.transform = CATransform3DMakeRotation(.pi / 2, 0, 0, 1)
        gradient.frame = bounds
        layer.insertSublayer(gradient, at: 0)
        return gradient
    }

    private var gradient: CAGradientLayer?

    @IBInspectable
    public var color1: UIColor? {
        didSet {
            updateColors()
        }
    }

    @IBInspectable
    public var color2: UIColor? {
        didSet {
            updateColors()
        }
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        gradient = createGradient()
        updateColors()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        gradient = createGradient()
        updateColors()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        gradient?.frame = bounds
    }

    private func updateColors() {
        guard
            let color1 = color1,
            let color2 = color2
        else {
            return
        }

        gradient?.colors = [color1.cgColor, color2.cgColor]
    }
}
