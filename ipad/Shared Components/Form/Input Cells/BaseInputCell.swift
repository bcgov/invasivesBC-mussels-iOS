//
//  BaseInputCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-31.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import UIKit

class BaseInputCell<Model: InputItem>: UICollectionViewCell,Theme {
    // MARK: Variables
    var model: Model?
    var inputDelegate: InputDelegate?
    
    // MARK: Class functions
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)

        // Specify you want _full width_
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)

        // Calculate the size (height) using Auto Layout
        let autoLayoutSize = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: autoLayoutSize)

        // Assign the new size to the layout attributes
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
    func beginListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.InputFieldshouldUpdate(notification:)), name: .InputFieldShouldUpdate, object: nil)
    }
    
    @objc func InputFieldshouldUpdate(notification: Notification) {
        guard let model = self.model, let notificationInput = notification.object as? InputItem, model.key == notificationInput.key else {return}
        self.updateValue(value: notificationInput.value)
    }
    
    func updateValue(value: InputValue) {}
    
    // MARK: Setup
    func setup(with model: Model, delegate: InputDelegate) {
        self.model = model
        self.inputDelegate = delegate
        initialize(with: model)
        beginListener()
    }
    
    func initialize(with model: Model) {}
    
    func emitChange() {
        NotificationCenter.default.post(name: .InputItemValueChanged, object: self.model)
    }
}
