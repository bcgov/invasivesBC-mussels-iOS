//
//  ViewFieldCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-11.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class ViewFieldCollectionViewCell: BaseInputCell<ViewField> {

    @IBOutlet weak var fieldHeader: UILabel!
    @IBOutlet weak var fieldValue: UILabel!

    private var dependencyKeys: [String] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    // MARK: Setup
    override func initialize(with model: ViewField) {
        self.fieldHeader.text = model.header
        
        if let computation = model.computation {
            for item in computation.dependees {
                self.dependencyKeys.append(item.item.key)
            }
        }
        
        style()
        computeField()
        addListeners()
    }
    
    private func addListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.inputItemValueChanged(notification:)), name: .InputItemValueChanged, object: nil)
    }
    
    @objc func inputItemValueChanged(notification: Notification) {
        guard let item: InputItem = notification.object as? InputItem else {return}
        if dependencyKeys.contains(item.key) {
            computeField()
        }
    }
    
    private func computeField() {
        guard let model = self.model, let computation = model.computation else {
            return
        }
        var current: Double = 0
        for item in computation.dependees {
            
            var _itemValue: Double?
            if let value = item.item.value.get(type: item.item.type) as? Double {
                _itemValue = value
            } else if let value = item.item.value.get(type: item.item.type) as? Int {
                _itemValue = Double(value)
            }
            guard item.isSatisfied(), let itemValue = _itemValue else {
                model.setValue(value: "")
                self.fieldValue.text = model.getValue()
                return
            }
            switch computation.rule {
            case .Multiply:
                current = current == 0 ? itemValue : current * itemValue
            case .Add:
                current = current + itemValue
            }
        }
        model.setValue(value: "\(current)")
        self.fieldValue.text = model.getValue()
        
    }
    
    override func style() {
        styleFieldHeader(label: fieldHeader)
    }
}
