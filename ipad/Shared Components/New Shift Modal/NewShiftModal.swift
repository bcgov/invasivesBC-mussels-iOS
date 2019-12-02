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
    var onStart: ((_ model: ShiftModel) -> Void)?
    var onCancel: (() -> Void)?
    var model: ShiftModel?
    weak var inputGroup: UIView?
    private var formResult: [String: Any?] = [String: Any]()
    
    // MARK: Outlets
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
        model.setDate(to: Date())
        model.setShouldSync(to: false)
        self.remove()
        return onClick(model)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func initialize(delegate: InputDelegate, onStart: @escaping (_ model: ShiftModel) -> Void, onCancel:  @escaping () -> Void) {
        self.onStart = onStart
        self.onCancel = onCancel
        setFixed(width: 550, height: 610)
        present()
        style()
        self.model = ShiftModel()
        generateInput(delegate: delegate)
        addListeners()
    }
    
    private func addListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.inputItemValueChanged(notification:)), name: .InputItemValueChanged, object: nil)
    }
    
    // MARK: Input Item Changed
    @objc func inputItemValueChanged(notification: Notification) {
        guard let item: InputItem = notification.object as? InputItem else {return}
        formResult[item.key] = item.value.get(type: item.type)
        // Set value in Realm object
        if let m = model {
            m.set(value: item.value.get(type: item.type) as Any, for: item.key)
        }
        print(model?.toDictionary())
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
