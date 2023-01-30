//
//  NullSwitchInputCollectionViewCell.swift
//  ipad
//
//  Created by Claveau, David LWRS:EX on 2023-01-30.
//  Copyright © 2023 Amir Shayegh. All rights reserved.
//

import UIKit

class NullSwitchInputCollectionViewCell: BaseInputCell<NullSwitchInput> {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var nullSwitchView: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }

    @IBAction func switchDidChange(_ sender: UISegmentedControl) {

        //set the new text color attributes on the selected segment's title
        sender.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)

        switch sender.selectedSegmentIndex {
            case 0:
                Alert.show(title: "No", message:"Nope")
            case 1:
                Alert.show(title:"Yes", message:"Yup")
            default:
                Alert.show(title:"Nil", message:"Nothin'")
        }
    }
    
    // MARK: Setup
    override func initialize(with model: NullSwitchInput) {
        self.headerLabel.text = model.header
//        self.switchView.isOn = model.value.get(type: model.type) as? Bool ?? false
        self.nullSwitchView.accessibilityValue = model.header.removeWhitespaces().lowercased()
        self.nullSwitchView.accessibilityLabel = model.header.removeWhitespaces().lowercased()
        self.accessibilityValue = "\(model.header.removeWhitespaces().lowercased())cell"
        self.accessibilityLabel = "\(model.header.removeWhitespaces().lowercased())cell"
    }
    
    // MARK: Style
    override func style() {
        styleFieldHeader(label: headerLabel)
    }
}
