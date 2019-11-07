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
    
    weak var inputGroup: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }
    
    public func setup(title: String, input items: [InputItem], delegate: InputDelegate) {
        self.inputGroup?.removeFromSuperview()
        self.titleLabel.text = title
        let inputGroup: InputGroupView = InputGroupView()
        
        self.inputGroup = inputGroup
        inputGroup.initialize(with: items, delegate: delegate, in: container)
    }
    
    private func style() {
        styleSectionTitle(label: titleLabel)
        styleDivider(view: divider)
    }

}
