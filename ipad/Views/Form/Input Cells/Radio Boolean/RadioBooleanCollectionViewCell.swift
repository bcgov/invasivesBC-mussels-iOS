//
//  RadioBooleanCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-25.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class RadioBooleanCollectionViewCell: BaseInputCell<RadioBoolean>  {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var radioIcon: UIImageView!
    @IBOutlet weak var radioView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: Setup
    override func initialize(with model: RadioBoolean) {
        self.headerLabel.text = model.header
        self.radioIcon.alpha = model.getValue() ?? false ? 1 : 0
        self.layoutIfNeeded()
        addGestureRecognizers()
        style()
    }
    
    private func addGestureRecognizers() {
        self.radioIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.onClick)))
        self.radioView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.onClick)))
    }
    
    @objc func onClick(sender : UITapGestureRecognizer) {
        guard let model = self.model else {return}
        let current: Bool = model.getValue() ?? false
        set(to: !current)
        self.emitChange()
    }
    
    func set(to on: Bool?) {
        guard let model = self.model else {return}
        model.setValue(value: on)
        
        UIView.animate(withDuration: SettingsConstants.shortAnimationDuration) {
            self.radioIcon.alpha = on ?? false ? 1 : 0
            self.layoutIfNeeded()
        }
    }
    
    // MARK: Style
    override func style() {
        makeCircle(view: radioView)
        radioView.layer.borderWidth = 1
        radioView.layer.borderColor = Colors.primary.cgColor
        styleFieldHeader(label: headerLabel)
    }
    
}
