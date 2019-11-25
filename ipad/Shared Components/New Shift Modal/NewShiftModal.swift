//
//  NewShiftModal.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-25.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import Modal

class NewShiftModal: ModalView, Theme {
    
    // MARK: Vatiables
    var onStart: (() -> Void)?
    var onCancel: (() -> Void)?
    var model: ShiftModel?
    weak var inputGroup: UIView?
    
    // MARK: Outlets
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var startNowButton: UIButton!
    @IBOutlet weak var inputContainer: UIView!
    
    
    public func initialize(delegate: InputDelegate, onStart: @escaping () -> Void, onCancel:  @escaping () -> Void) {
        self.onStart = onStart
        self.onCancel = onCancel
        setFixed(width: 550, height: 610)
        present()
        style()
        self.model = ShiftModel()
        generateInput(delegate: delegate)
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        guard let onClick = self.onCancel else {return}
        
        self.remove()
        return onClick()
    }
    
    @IBAction func startNowAction(_ sender: UIButton) {
        guard let onClick = self.onStart else {return}
        
        self.remove()
        return onClick()
    }
    
    func generateInput(delegate: InputDelegate) {
        guard let model = self.model else {return}
        let fields = model.getShiftStartFields(forModal: true, editable: true)
        self.inputGroup?.removeFromSuperview()
        let inputGroup: InputGroupView = InputGroupView()
        self.inputGroup = inputGroup
        inputGroup.initialize(with: fields, delegate: delegate, in: inputContainer)
    }
    
    func style() {
        styleCard(layer: self.layer)
        styleSectionTitle(label: headerLabel)
        styleFillButton(button: startNowButton)
        styleHollowButton(button: cancelButton)
    }
}
