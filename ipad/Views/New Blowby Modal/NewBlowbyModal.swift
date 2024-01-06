//
//  NewBlowbyModal.swift
//  ipad
//
//  Created by Sustainment Team on 2023-01-04.
//  Copyright © 2024 Sustainment Team. All rights reserved.
//

import Foundation
import Modal

class NewBlowbyModal: ModalView, Theme {
    
    // MARK: Variables
    var onStart: ((_ model: ShiftModel) -> Void)?
    var onCancel: (() -> Void)?
    var model: ShiftModel?
    var newBlowBy: BlowbyModel = BlowbyModel()
    weak var inputGroup: UIView?
    
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
    
  /// Action taken when the Confirmation button is pressed
    @IBAction func startNowAction(_ sender: UIButton) {
        guard let model = self.model, let onClick = self.onStart else {return}
        
        // If (Valid) Add Blowby, remove and return
        var invalidFields: [String] = []
        if !newBlowBy.reportedToRapp {
            invalidFields.append("Reported to RAPP")
        }
        if newBlowBy.watercraftComplexity == "" {
            invalidFields.append("Watercraft Complexity")
        }
        if newBlowBy.timeStamp == "" {
            invalidFields.append("Blowby Time")
        }
        
        if !invalidFields.isEmpty {
            Alert.show(title: "Can't continue", message: "Please complete the following fields: " + invalidFields.joined(separator: ", "))
        } else {
            _ = model.addBlowby(blowby: newBlowBy);
            self.remove()
            return onClick(model)
        }
    }

    /// Entrance for modal, Initializer sets the model to the current shift we are editing in
  func initialize(shift: ShiftModel, delegate: InputDelegate, onStart: @escaping (_ model: ShiftModel) -> Void, onCancel:  @escaping () -> Void) {
      self.onStart = onStart
      self.onCancel = onCancel
      setFixed(width: 550, height: 400)
      present()
      style()

      // Use the passed shift model instead of creating a new one
      self.model = shift
    
      generateInput(delegate: delegate)
      addListeners()
      accessibilityLabel = "newShiftModal"
      accessibilityValue = "newShiftModal"
  }

    
    private func addListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.inputItemValueChanged(notification:)), name: .InputItemValueChanged, object: nil)
    }
    
    // MARK: Input Item Changed
    @objc func inputItemValueChanged(notification: Notification) {
        guard let item: InputItem = notification.object as? InputItem else {return}
        // Set value in Realm object
      self.newBlowBy.set(value: item.value.get(type: item.type) as Any, for: item.key)
    }
    
    func generateInput(delegate: InputDelegate) {
        let fields = newBlowBy.getThisBlowbyFields(editable: true, modalSize: true)
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
