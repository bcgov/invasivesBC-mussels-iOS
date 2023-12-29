//
//  BaseShiftOverviewCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-21.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class BaseBlowByOverviewCollectionViewCell: UICollectionViewCell, Theme {
    
    // MARK: Variables
    var model: BlowByModel?
    // MARK: Variables
    var completion: (()-> Void)?
    
    // MARK: Setup
    func setup(object: BlowByModel, callback: (()-> Void)? = nil) {
        
        self.model = object
        if callback != nil {
            self.completion = callback!
        }
        autofill()
        style()
    }
    func autofill() { }
    func style() {}
    
}
