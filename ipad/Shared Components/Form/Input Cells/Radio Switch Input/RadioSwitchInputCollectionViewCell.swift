//
//  RadioSwitchInputCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-07.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class RadioSwitchInputCollectionViewCell: BaseInputCell<RadioSwitchInput> {
    
    @IBOutlet weak var fieldHeader: UILabel!
    
    @IBOutlet weak var noView: UIView!
    @IBOutlet weak var noImageView: UIImageView!
    @IBOutlet weak var noLabel: UILabel!
    @IBOutlet weak var yesView: UIView!
    @IBOutlet weak var yesImageView: UIImageView!
    @IBOutlet weak var yesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: Setup
    override func initialize(with model: RadioSwitchInput) {
        self.fieldHeader.text = model.header
        style()
        if let initialValue = model.getValue() {
            switch initialValue {
            case true:
                self.yesImageView.alpha = 1
                self.noImageView.alpha = 0
            case false:
                self.yesImageView.alpha = 0
                self.noImageView.alpha = 1
            }
            self.layoutIfNeeded()
        }
        addGestureRecognizers()
    }
    
    private func addGestureRecognizers() {
        self.yesImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.selectedYes)))
        self.yesLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.selectedYes)))
        self.yesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.selectedYes)))
        self.noImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.selectedNo)))
        self.noLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.selectedNo)))
        self.noView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.selectedNo)))
    }
    
    @objc func selectedYes(sender : UITapGestureRecognizer) {
        set(to: true)
        self.emitChange()
    }
    
    @objc func selectedNo(sender : UITapGestureRecognizer) {
        set(to: false)
        self.emitChange()
    }
    
    func set(to on: Bool?) {
        guard let model = self.model else {return}
        model.setValue(value: on)
        setYes(on: false)
        setNo(on: false)
        if let yesSelected = on {
            if yesSelected {
                setYes(on: true)
            } else {
                setNo(on: true)
            }
        }
    }
    
    func setYes(on: Bool) {
        UIView.animate(withDuration: SettingsConstants.shortAnimationDuration) {
            self.yesImageView.alpha = on ? 1 : 0
        }
    }
    
    func setNo(on: Bool) {
        UIView.animate(withDuration: SettingsConstants.shortAnimationDuration) {
            self.noImageView.alpha = on ? 1 : 0
        }
    }
    
    // MARK: Style
    private func style() {
        makeCircle(view: noView)
        makeCircle(view: yesView)
        noView.layer.borderWidth = 1
        noView.layer.borderColor = Colors.primary.cgColor
        yesView.layer.borderWidth = 1
        yesView.layer.borderColor = Colors.primary.cgColor

        styleFieldHeader(label: fieldHeader)
    }
}
