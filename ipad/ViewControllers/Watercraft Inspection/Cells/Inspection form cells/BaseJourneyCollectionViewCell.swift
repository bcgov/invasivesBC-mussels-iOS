//
//  BaseJourneyCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-12-05.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class BaseJourneyCollectionViewCell: UICollectionViewCell {
    
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
    
    @objc func inputItemChanged(notification: Notification) {
        guard let inputgroupView = self.inputGroup as? InputGroupView, let changedInput = notification.object as? InputItem else {return}
        let groupInputsKeys = inputgroupView.inputItems.map{ $0.key}
        // Check if an item in this group changed
        if groupInputsKeys.contains(changedInput.key) {
            let splitKey = changedInput.key.split(separator: "-")
            let key = String(splitKey[1])
            // Find changed key (cleaned, without index and type of journey)
            switch key {
            case waterbodyKey:
                // Change dropdown items of cities for this group
                for item in inputgroupView.inputItems where item.key.contains(nearestCityKey) {
                    guard let dropdownItem = item as? DropdownInput, let changedValue = changedInput.value.get(type: changedInput.type) as? String else { return }
                    dropdownItem.dropdownItems = DropdownHelper.shared.dropdown(from: Storage.shared.getCities(nearWaterBody: changedValue))
                    return
                }
            case nearestCityKey:
                return
            case provinceKey:
                // Change dropdown of provinces for this group
                for item in inputgroupView.inputItems where item.key.contains(waterbodyKey) {
                    guard let dropdownItem = item as? DropdownInput, let changedValue = changedInput.value.get(type: changedInput.type) as? String else { return }
                    dropdownItem.dropdownItems = DropdownHelper.shared.dropdown(from: Storage.shared.getWaterbodies(inProvince: changedValue))
                    return
                }
            default:
                return
            }
        }
    }
}
