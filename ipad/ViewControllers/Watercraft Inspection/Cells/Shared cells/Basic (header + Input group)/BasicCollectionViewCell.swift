//
//  BasicCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-04.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class BasicCollectionViewCell: UICollectionViewCell, Theme {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var leadingMargin: NSLayoutConstraint!
    @IBOutlet weak var trailingMargin: NSLayoutConstraint!
    
    weak var inputGroup: UIView?
    
    var showBox = false
    var showDivider = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }
    
    public func setup(title: String, input items: [InputItem], delegate: InputDelegate, boxed: Bool? = false, showDivider: Bool? = true, padding: CGFloat? = 0) {
        if let extraPadding = padding {
            self.leadingMargin.constant = extraPadding
            self.trailingMargin.constant = extraPadding
        }
        self.inputGroup?.removeFromSuperview()
        self.titleLabel.text = title
        let inputGroup: InputGroupView = InputGroupView()
        self.inputGroup = inputGroup
        inputGroup.initialize(with: items, delegate: delegate, in: container)
        
        self.showBox = boxed ?? false
        self.showDivider = showDivider ?? true
        
        style()
    }
    
    private func style() {
        styleSectionTitle(label: titleLabel)
        styleBox()
        styleDivider()
    }
    
    private func styleBox() {
        if showBox {
            self.layer.cornerRadius = 3
            self.layer.borderWidth = 1
            self.layer.borderColor = UIColor(red:0.8, green:0.81, blue:0.82, alpha:1).cgColor
        } else {
            self.layer.borderWidth = 0
        }
    }
    
    private func styleDivider() {
        if showDivider {
            divider.alpha = 1
            styleDivider(view: divider)
        } else {
            divider.alpha = 0
        }
    }
    
}
