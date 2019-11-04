//
//  SwitchInputCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-01.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class SwitchInputCollectionViewCell: BaseInputCell<SwitchInput> {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var switchView: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        guard let model = self.model else {return}
        model.value.set(value: sender.isOn, type: model.type)
        self.emitChange()
    }
    
    // MARK: Setup
    override func initialize(with model: SwitchInput) {
        self.headerLabel.text = model.header
        self.switchView.isOn = model.value.get(type: model.type) as? Bool ?? false
    }
    
    // MARK: Style
    private func style() {
        styleFieldHeader(label: headerLabel)
    }
}
