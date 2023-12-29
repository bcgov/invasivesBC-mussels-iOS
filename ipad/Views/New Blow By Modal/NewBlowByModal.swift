//
//  NewBlowByModal.swift
//  ipad
//
//  Created by Matthew Logan on 2023-12-29.
//  Copyright © 2023 Amir Shayegh. All rights reserved.
//

import Foundation
import Modal

class NewBlowByModal: ModalView, Theme {
    var onStart: ((_ model: BlowByModel) -> Void)?
    var onCancel: (() -> Void)?
    var model: BlowByModel?
    weak var inputGroup: UIView?
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var startNowButton: UIButton!
    @IBOutlet weak var inputContainer: UIView!
    
    @IBAction func cancelAction(_ sender: UIButton) {
        guard let onClick = self.onCancel else {return}
        self.remove()
        return onClick()
    }
    
    @IBAction func startNowAction(_ sender: UIButton) {
        guard let model = self.model, let onClick = self.onStart else {return}
        self.remove()
        return onClick(model)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func initialize(delegate: InputDelegate, onStart: @escaping (_ model: BlowByModel) -> Void, onCancel: @escaping () -> Void) {
        self.onStart = onStart
        self.onCancel = onCancel
        setFixed(width: 550, height: 400)
        present()
        style()
        self.model = BlowByModel()
        generateInput(delegate: delegate)
        addListeners()
        accessibilityLabel = "newBlowByModal"
        accessibilityValue = "newBlowByModal"
    }
    
    private func addListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.inputItemValueChanged(notification:)), name: .InputItemValueChanged, object: nil)
    }
    
    @objc func inputItemValueChanged(notification: Notification) {
        guard let item: InputItem = notification.object as? InputItem else {return}
        if let m = model {
            m.set(value: item.value.get(type: item.type) as Any, for: item.key)
        }
    }
    
    func generateInput(delegate: InputDelegate){
        guard let model = self.model else {return}
        let fields = model.getBlowByStartFields(forModal: true, editable: true)
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
