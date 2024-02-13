//
//  BlankCollectionViewCell.swift
//  ipad
//
//  Created by Claveau, David LWRS:EX on 2024-02-12.
//  Copyright © 2024 Amir Shayegh. All rights reserved.
//

import UIKit

class BlankCollectionViewCell: UICollectionViewCell, Theme {

    @IBOutlet weak var blank: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(visible: Bool) {
        blank.alpha = visible ? 1 : 0
    }

}
