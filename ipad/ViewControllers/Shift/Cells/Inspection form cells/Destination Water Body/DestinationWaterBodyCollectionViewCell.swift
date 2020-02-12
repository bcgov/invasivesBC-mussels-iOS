//
//  DestinationWaterBodyCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-05.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class DestinationWaterBodyCollectionViewCell: BaseJourneyCollectionViewCell, Theme {
    
    @IBOutlet weak var fieldHeader: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cellContainer: UIView!
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
    
    func setup(with model: DestinationWaterbodyModel, isEditable: Bool, delegate: InputDelegate, onDelete: @escaping ()-> Void) {
        self.onDelete = onDelete
        self.delegate = delegate
        if let waterbody = Storage.shared.getWaterbodyModel(withId: model.remoteId) {
            self.inputField.text = "\(waterbody.name), \(waterbody.province), \(waterbody.country) (\(waterbody.closest))"
        }
        style()
        self.deleteButton.alpha = isEditable ? 1 : 0
    }
    
    private func style() {
        deleteButton.tintColor = Colors.primary
        styleFieldHeader(label: fieldHeader)
        styleFieldInput(textField: inputField)
        inputField.isEnabled = false
        contentView.backgroundColor = UIColor.yellow
        contentView.layer.cornerRadius = 3
        contentView.backgroundColor = UIColor.white
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor(red:0.8, green:0.81, blue:0.82, alpha:1).cgColor
    }
    
}
