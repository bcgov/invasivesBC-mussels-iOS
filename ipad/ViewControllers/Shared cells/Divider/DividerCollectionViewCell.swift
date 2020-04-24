//
//  DividerCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-05.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class DividerCollectionViewCell: UICollectionViewCell, Theme {

    @IBOutlet weak var divider: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        style()
    }
    
    func setup(visible: Bool) {
        divider.alpha = visible ? 1 : 0
    }
    
    func style() {
        styleDivider(view: divider)
    }

}
