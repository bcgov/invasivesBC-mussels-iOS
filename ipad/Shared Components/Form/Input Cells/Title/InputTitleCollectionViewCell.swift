//
//  InputTitleCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2020-01-21.
//  Copyright © 2020 Amir Shayegh. All rights reserved.
//

import UIKit

class InputTitleCollectionViewCell:  BaseInputCell<InputTitle> {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: Setup
    override func initialize(with model: InputTitle) {
        self.model = model
        if let titleName = model.value.get(type: .Title) as? String {
            titleLabel.text = titleName
        } else {
            titleLabel.text = ""
        }
        style()
    }
    
    private func style() {
        styleFieldHeader(label: titleLabel)
    }

}
