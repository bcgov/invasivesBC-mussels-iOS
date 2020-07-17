//
//  NewFormViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2020-07-17.
//  Copyright © 2020 Amir Shayegh. All rights reserved.
//

import UIKit

class NewFormViewController: BaseViewController {
    
    var model: NewFormModel?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var fieldsContainer: UIView!
    @IBOutlet weak var fieldsContainerHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showForm()
        addListeners()
        style()
    }
    
    private func addListeners() {
        NotificationCenter.default.removeObserver(self, name: .InputItemValueChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.inputItemValueChanged(notification:)), name: .InputItemValueChanged, object: nil)
    }
    
    @objc func inputItemValueChanged(notification: Notification) {
        guard let item: InputItem = notification.object as? InputItem else {return}
        // Set value in Realm object
        if let m = model {
            m.set(value: item.value.get(type: item.type) as Any, for: item.key)
        }
    }
    
    func showForm() {
        self.model = NewFormModel()
        guard let _model = model else {return}
        let inputGroup: InputGroupView = InputGroupView()
        inputGroup.initialize(with: _model.getFieldConfigs(editable: true), delegate: self, in: self.fieldsContainer)
        fieldsContainerHeight.constant = InputGroupView.estimateContentHeight(for: _model.getFieldConfigs(editable: true))
    }
    
    func style() {
        fieldsContainer.backgroundColor = .clear
        fieldsContainer.layer.borderWidth = 2
        fieldsContainer.layer.borderColor = Colors.primary.cgColor
        titleLabel.font = Fonts.getPrimaryBold(size: 27)
    }
}
