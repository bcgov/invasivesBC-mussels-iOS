//
//  BaseViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-29.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, Theme {
    
    // MARK: Constants
    let visibleAlpha: CGFloat = 1
    let invisibleAlpha: CGFloat = 0
    
    // MARK: Variables
    var currentPopOver: UIViewController?
    
    // MARK: ViewController Functions
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: Event handlers
    func whenLandscape() {}
    func whenPortrait() {}
    func orientationChanged() {}
    
    // MARK: Utilities
    public func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: Popover
    private func showPopOver(on: UIButton, popOverVC: UIViewController, height: Double, width: Double, arrowColor: UIColor?) {
        self.view.endEditing(true)
        dismissPopOver()
        popOverVC.modalPresentationStyle = .popover
        popOverVC.preferredContentSize = CGSize(width: width, height: height)
        guard let popover = popOverVC.popoverPresentationController else {return}
        popover.backgroundColor = arrowColor ?? UIColor.white
        popover.permittedArrowDirections = .any
        popover.sourceView = on
        popover.sourceRect = CGRect(x: on.bounds.midX, y: on.bounds.midY, width: 0, height: 0)
        self.currentPopOver = popOverVC
        present(popOverVC, animated: true, completion: nil)
    }
    
    private func showPopOver(on: CALayer, inView: UIView, vc: UIViewController, height: Double, width: Double, arrowColor: UIColor?) {
        self.view.endEditing(true)
        dismissPopOver()
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: width, height: height)
        guard let popover = vc.popoverPresentationController else {return}
        popover.backgroundColor = arrowColor ?? UIColor.white
        popover.permittedArrowDirections = .any
        popover.sourceView = inView
        popover.sourceRect = CGRect(x: on.frame.midX, y: on.frame.midY, width: 0, height: 0)
        self.currentPopOver = vc
        present(vc, animated: true, completion: nil)
    }
    
    // dismisses the last popover added
    public func dismissPopOver() {
        if let popOver = self.currentPopOver {
            popOver.dismiss(animated: false, completion: nil)
        }
    }
    
    public func showOptions(options: [OptionType], on button: UIButton, completion: @escaping (_ option: OptionType) -> Void) {
        let optionsObject = Options()
        let optionsViewController = optionsObject.getVC()
        let popoverSize = optionsViewController.setup(options: options, completion: completion)
        showPopOver(on: button, popOverVC: optionsViewController, height: popoverSize.height, width: popoverSize.width, arrowColor: nil)
    }
    
    public func showDropdown(items: [DropdownModel], header: String? = "", on button: UIButton, enableOtherOption: Bool? = false, completion: @escaping (_ result: DropdownModel?) -> Void) {
        let dropdownObject = Dropdown()
        let dropdownViewController = dropdownObject.getVC()
        let popoverSize = dropdownViewController.setup(objects: items, onButton: button, otherEnabled: enableOtherOption ?? false, completion: completion)
        showPopOver(on: button, popOverVC: dropdownViewController, height: popoverSize.height, width: popoverSize.width, arrowColor: nil)
    }
    
    public func showDropdownMultiSelect(items: [DropdownModel], selectedItems: [DropdownModel], header: String? = "", on button: UIButton, enableOtherOption: Bool? = false, completion: @escaping (_ done: Bool,_ result: [DropdownModel]?) -> Void) {
        let dropdownObject = Dropdown()
        let dropdownViewController = dropdownObject.getVC()
        let popoverSize = dropdownViewController.setupMultiSelect(header: header, selectedItems: selectedItems, items: items, otherEnabled: enableOtherOption ?? false, completion: completion)
        showPopOver(on: button, popOverVC: dropdownViewController, height: popoverSize.height, width: popoverSize.width, arrowColor: nil)
    }
    
    public func showDropdownMultiSelectLive(items: [DropdownModel], selectedItems: [DropdownModel], header: String? = "", on button: UIButton, enableOtherOption: Bool? = false, completion: @escaping (_ result: [DropdownModel]?) -> Void) {
        let dropdownObject = Dropdown()
        let dropdownViewController = dropdownObject.getVC()
        let popoverSize = dropdownViewController.setupMultiSelectLive(header: header, selectedItems: selectedItems, items: items, otherEnabled: enableOtherOption ?? false, completion: completion)
        showPopOver(on: button, popOverVC: dropdownViewController, height: popoverSize.height, width: popoverSize.width, arrowColor: nil)
    }
    
    // MARK: Animations
    public func animateIt() {
        UIView.animate(withDuration: SettingsConstants.shortAnimationDuration, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    public func animateFor(time: Double) {
        UIView.animate(withDuration: time, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: Custom messages
    public func fadeLabelMessage(label: UILabel, text: String) {
        let originalText: String = label.text ?? ""
        let originalTextColor: UIColor = label.textColor
        // fade out current text
        UIView.animate(withDuration: SettingsConstants.shortAnimationDuration, animations: {
            label.alpha = self.invisibleAlpha
            self.view.layoutIfNeeded()
        }) { (done) in
            // change text
            label.text = text
            // fade in warning text
            UIView.animate(withDuration: SettingsConstants.shortAnimationDuration, animations: {
                label.textColor = Colors.accent.red
                label.alpha = self.visibleAlpha
                self.view.layoutIfNeeded()
            }, completion: { (done) in
                // revert after 3 seconds
                UIView.animate(withDuration: SettingsConstants.shortAnimationDuration, delay: 3, animations: {
                    // fade out text
                    label.alpha = self.invisibleAlpha
                    self.view.layoutIfNeeded()
                }, completion: { (done) in
                    // change text
                    label.text = originalText
                    // fade in text
                    UIView.animate(withDuration: SettingsConstants.shortAnimationDuration, animations: {
                        label.textColor = originalTextColor
                        label.alpha = self.visibleAlpha
                        self.view.layoutIfNeeded()
                    })
                })
            })
        }
    }
    
    // MARK: Statusbar
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // MARK: Screen Rotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.dismissPopOver()
            self.notifyOrientationChange()
            if size.width > size.height {
                self.whenLandscape()
            } else {
                self.whenPortrait()
            }
        }
    }
    
    private func notifyOrientationChange() {
        orientationChanged()
        NotificationCenter.default.post(name: .screenOrientationChanged, object: nil)
    }
}

