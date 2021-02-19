//
//  BaseJourneyCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-12-05.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class BaseJourneyCollectionViewCell: UICollectionViewCell {
    
    // MARK: Variables
    weak var inputGroup: UIView?
    private var waterbodyKey = "waterbody"
    private var nearestCityKey = "nearestCity"
    private var provinceKey = "province"
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func beginFilterListener() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(self.inputItemChanged(notification:)), name: .InputItemValueChanged, object: nil)
    }
    
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
    
    func fieldChanged(key: String, value changedValue: String) {
        guard let inputgroupView = self.inputGroup as? InputGroupView else {return}
        switch key {
        case waterbodyKey:
            var item1: InputItem? = nil
            var item2: InputItem? = nil
            // Change dropdown items of Cities for this group
            for item in inputgroupView.inputItems where item.key.contains(nearestCityKey) {
                guard let dropdownItem = item as? DropdownInput else { return }
                dropdownItem.dropdownItems = DropdownHelper.shared.dropdown(from: Storage.shared.getCities(nearWaterBody: changedValue), sort: false)
                if dropdownItem.dropdownItems.count == 1, let firstItem = dropdownItem.dropdownItems.first {
                    dropdownItem.setValue(value: firstItem.display)
                    NotificationCenter.default.post(name: .InputFieldShouldUpdate, object: dropdownItem)
                    item1 = dropdownItem
                } else if
                    let currentValue = dropdownItem.getValue(),
                    !DropdownHelper.shared.dropdownContains(key: currentValue, dropdownItems: dropdownItem.dropdownItems)
                {
                    dropdownItem.setValue(value: "")
                    NotificationCenter.default.post(name: .InputFieldShouldUpdate, object: dropdownItem)
                    item1 = dropdownItem
                }
            }
            
            // Change the dropdown items of Provinces in this group
            for item in inputgroupView.inputItems where item.key.contains(provinceKey) {
                guard let dropdownItem = item as? DropdownInput else { return }
                dropdownItem.dropdownItems = DropdownHelper.shared.dropdown(from: Storage.shared.getProvinces(withWaterBody: changedValue), sort: true)
                if dropdownItem.dropdownItems.count == 1, let firstItem = dropdownItem.dropdownItems.first {
                    dropdownItem.setValue(value: firstItem.display)
                    NotificationCenter.default.post(name: .InputFieldShouldUpdate, object: dropdownItem)
                    item2 = dropdownItem
                } else if
                    let currentValue = dropdownItem.getValue(),
                    !DropdownHelper.shared.dropdownContains(key: currentValue, dropdownItems: dropdownItem.dropdownItems)
                {
                    dropdownItem.setValue(value: "")
                    NotificationCenter.default.post(name: .InputFieldShouldUpdate, object: dropdownItem)
                    item2 = dropdownItem
                }
            }
            
            if let itemToUpdate = item1 as? DropdownInput {
                NotificationCenter.default.post(name: .journeyItemValueChanged, object: itemToUpdate)
            }
            
            if let itemToUpdate = item2 as? DropdownInput {
                NotificationCenter.default.post(name: .journeyItemValueChanged, object: itemToUpdate)
            }
            
        case nearestCityKey:
            var item1: InputItem? = nil
            var item2: InputItem? = nil
            // Change the dropdown items of Water bodies in this group
            for item in inputgroupView.inputItems where item.key.contains(waterbodyKey) {
                guard let dropdownItem = item as? DropdownInput else { return }
                dropdownItem.dropdownItems = DropdownHelper.shared.dropdown(from: Storage.shared.getWaterbodies(nearCity: changedValue), sort: false)
                if dropdownItem.dropdownItems.count == 1, let firstItem = dropdownItem.dropdownItems.first {
                    dropdownItem.setValue(value: firstItem.display)
                    NotificationCenter.default.post(name: .InputFieldShouldUpdate, object: dropdownItem)
                    item1 = dropdownItem
                } else if
                    let currentValue = dropdownItem.getValue(),
                    !DropdownHelper.shared.dropdownContains(key: currentValue, dropdownItems: dropdownItem.dropdownItems)
                {
                    dropdownItem.setValue(value: "")
                    NotificationCenter.default.post(name: .InputFieldShouldUpdate, object: dropdownItem)
                    item1 = dropdownItem
                }
            }
            
            // Change the dropdown items of Provinces in this group
            for item in inputgroupView.inputItems where item.key.contains(provinceKey) {
                guard let dropdownItem = item as? DropdownInput else { return }
                dropdownItem.dropdownItems = DropdownHelper.shared.dropdown(from: Storage.shared.getProvinces(withCity: changedValue), sort: true)
                if dropdownItem.dropdownItems.count == 1, let firstItem = dropdownItem.dropdownItems.first {
                    dropdownItem.setValue(value: firstItem.display)
                    NotificationCenter.default.post(name: .InputFieldShouldUpdate, object: dropdownItem)
                    item2 = dropdownItem
                } else if
                    let currentValue = dropdownItem.getValue(),
                    !DropdownHelper.shared.dropdownContains(key: currentValue, dropdownItems: dropdownItem.dropdownItems)
                {
                    dropdownItem.setValue(value: "")
                    NotificationCenter.default.post(name: .InputFieldShouldUpdate, object: dropdownItem)
                    item2 = dropdownItem
                }
            }
            
            if let itemToUpdate = item1 as? DropdownInput {
                NotificationCenter.default.post(name: .journeyItemValueChanged, object: itemToUpdate)
            }
            
            if let itemToUpdate = item2 as? DropdownInput {
                NotificationCenter.default.post(name: .journeyItemValueChanged, object: itemToUpdate)
            }
            
        case provinceKey:
            var item1: InputItem? = nil
            var item2: InputItem? = nil
            // Change dropdown of waterbodies for this group
            for item in inputgroupView.inputItems where item.key.contains(waterbodyKey) {
                guard let dropdownItem = item as? DropdownInput else { return }
                dropdownItem.dropdownItems = DropdownHelper.shared.dropdown(from: Storage.shared.getWaterbodies(inProvince: changedValue), sort: false)
                if dropdownItem.dropdownItems.count == 1, let firstItem = dropdownItem.dropdownItems.first {
                    dropdownItem.setValue(value: firstItem.display)
                    NotificationCenter.default.post(name: .InputFieldShouldUpdate, object: dropdownItem)
                    item1 = dropdownItem
                } else if
                    let currentValue = dropdownItem.getValue(),
                    !DropdownHelper.shared.dropdownContains(key: currentValue, dropdownItems: dropdownItem.dropdownItems)
                {
                    dropdownItem.setValue(value: "")
                    NotificationCenter.default.post(name: .InputFieldShouldUpdate, object: dropdownItem)
                    item1 = dropdownItem
                }
            }
            
            // Change dropdown items of Cities for this group
            for item in inputgroupView.inputItems where item.key.contains(nearestCityKey) {
                guard let dropdownItem = item as? DropdownInput else { return }
                dropdownItem.dropdownItems = DropdownHelper.shared.dropdown(from: Storage.shared.getCities(inProvince: changedValue), sort: false)
                if dropdownItem.dropdownItems.count == 1, let firstItem = dropdownItem.dropdownItems.first {
                    dropdownItem.setValue(value: firstItem.display)
                    NotificationCenter.default.post(name: .InputFieldShouldUpdate, object: dropdownItem)
                    item2 = dropdownItem
                } else if
                    let currentValue = dropdownItem.getValue(),
                    !DropdownHelper.shared.dropdownContains(key: currentValue, dropdownItems: dropdownItem.dropdownItems)
                {
                    dropdownItem.setValue(value: "")
                    item2 = dropdownItem
                }
            }
            
            if let itemToUpdate = item1 as? DropdownInput {
                NotificationCenter.default.post(name: .journeyItemValueChanged, object: itemToUpdate)
            }
            
            if let itemToUpdate = item2 as? DropdownInput {
                NotificationCenter.default.post(name: .journeyItemValueChanged, object: itemToUpdate)
            }
            
        default:
            return
        }
    }
    
    @objc func inputItemChanged(notification: Notification) {
        guard let inputgroupView = self.inputGroup as? InputGroupView, let changedInput = notification.object as? InputItem, let changedValue = changedInput.value.get(type: changedInput.type) as? String else {return}
        let groupInputsKeys = inputgroupView.inputItems.map{ $0.key}
        // Check if an item in this group changed
        if groupInputsKeys.contains(changedInput.key) {
            let splitKey = changedInput.key.split(separator: "-")
            let key = String(splitKey[1])
            // Find changed key (cleaned, without index and type of journey)
            // And change other fields accordingly
            fieldChanged(key: key, value: changedValue);
        }
    }
}
