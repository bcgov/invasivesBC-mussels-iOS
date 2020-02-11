//
//  PreviousWaterBodyCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-05.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class PreviousWaterBodyCollectionViewCell: BaseJourneyCollectionViewCell, Theme {
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cellContainer: UIView!
    @IBOutlet weak var fieldHeader: UILabel!
    @IBOutlet weak var inputField: UITextField!
    
    var onDelete: (()-> Void)?
    var delegate: InputDelegate?
    
    @IBAction func optionsAction(_ sender: UIButton) {
        guard let onDelete = onDelete, let delegate = delegate else {return}
        delegate.showOptionsDelegate(options: [.Delete], on: sender) { (selected) in
            if selected == .Delete {
                return onDelete()
            }
        }
    }
    
    func setup(with model: PreviousWaterbodyModel, delegate: InputDelegate, onDelete: @escaping ()-> Void) {
//        self.inputGroup?.removeFromSuperview()
//        let inputGroup: InputGroupView = InputGroupView()
//        self.inputGroup = inputGroup
//        inputGroup.initialize(with: items, delegate: delegate, in: inputGroupContainer)
        self.onDelete = onDelete
        self.delegate = delegate
        if let waterbody = Storage.shared.getWaterbodyModel(withId: model.remoteId) {
            self.inputField.text = "\(waterbody.name), \(waterbody.province), \(waterbody.country) (\(waterbody.closest))"
        }
        style()
        beginFilterListener()
    }
    
    private func style() {
        deleteButton.tintColor = Colors.primary
        styleFieldHeader(label: fieldHeader)
        styleFieldInput(textField: inputField)
        inputField.isEnabled = false
    }
}
