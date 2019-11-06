//
//  DestinationWaterBodyCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-05.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class DestinationWaterBodyCollectionViewCell: UICollectionViewCell, Theme {

    @IBOutlet weak var cellContainer: UIView!
    @IBOutlet weak var inputGroupContainer: UIView!
    
    var completion: (()-> Void)?
    var delegate: InputDelegate?

    @IBAction func optionsAction(_ sender: UIButton) {
        guard let onDelete = completion, let delegate = delegate else {return}
        delegate.showOptionsDelegate(options: [.Delete], on: sender) { (selected) in
            if selected == .Delete {
                return onDelete()
            }
        }
    }
    
    func setup(with items: [InputItem], delegate: InputDelegate, onDelete: @escaping ()-> Void) {
        let inputGroup: InputGroupView = InputGroupView()
        inputGroup.initialize(with: items, delegate: delegate, in: inputGroupContainer)
        completion = onDelete
        self.delegate = delegate
        style()
    }
    
    private func style() {
    }

}
