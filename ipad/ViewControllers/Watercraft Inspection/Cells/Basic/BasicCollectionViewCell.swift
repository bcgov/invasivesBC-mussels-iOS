//
//  BasicCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-04.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class BasicCollectionViewCell: UICollectionViewCell, Theme {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var divider: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }
    
    public func setup(title: String, input Items: [InputItem], delegate: InputDelegate) {
        self.titleLabel.text = title
        let inputGroup: InputGroupView = InputGroupView()
        inputGroup.initialize(with: Items, delegate: delegate, in: container)
    }
    
    private func style() {
        styleSectionTitle(label: titleLabel)
        styleDivider(view: divider)
    }

}
