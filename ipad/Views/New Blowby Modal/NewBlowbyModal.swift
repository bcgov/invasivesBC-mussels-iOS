//
//  NewBlowbyModal.swift
//  ipad
//
//  Created by Sustainment Team on 2023-01-04.
//  Copyright © 2024 Sustainment Team. All rights reserved.
//

import Foundation
import Modal
import UIKit

class NewBlowbyModal: ModalView, Theme {
    
    // MARK: Variables
    var onStart: ((_ model: ShiftModel) -> Void)?
    var onCancel: (() -> Void)?
    var onSubmit: (() -> Void)?
    var model: ShiftModel?
    var newBlowBy: BlowbyModel?
    weak var inputGroup: UIView?
    var editingBlowby: Bool = false;
    
    // MARK: Outlets
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var startNowButton: UIButton!
    @IBOutlet weak var inputContainer: UIView!
  
  /// When cancel button is pressed, responds by closing modal
    @IBAction func cancelAction(_ sender: UIButton) {
        guard let onClick = self.onCancel else {return}
        self.remove()
        return onClick()
    }
  
  /// When delete button is pressed, sends confirmation for users action then deletes Blowby from list
    @IBAction func deleteAction(_ sender: UIButton) {
        Alert.show(title: "Deleting Blowby", message: "Would you like to delete this Blowby?", yes: {
          self.model?.deleteBlowby(blowbyToDelete: self.newBlowBy!)
          self.onSubmit?()
          self.remove()
        }) {
            return
        }

    }
  
  /// When button is pressed, validates information in the BlowbyModel, alerting user of unfilled fields
  /// If we are not in edit mode, new BlowbyModel is appended to list of blowbys, and modal closes
  /// If we are in in edit mode, Modal only closes.
    @IBAction func startNowAction(_ sender: UIButton) {
        guard let model = self.model, let onClick = self.onStart else {return}
        
        // If (Valid) Add Blowby, remove and return
        var invalidFields: [String] = []
        if newBlowBy!.timeStamp == "" {
            invalidFields.append("Blowby Time")
        }
        if newBlowBy!.watercraftComplexity == "" {
            invalidFields.append("Watercraft Complexity")
        }
        if !invalidFields.isEmpty {
            Alert.show(title: "Can't continue", message: "Please complete the following fields:\n-" + invalidFields.joined(separator: "\n-"))
        } else {
          if(!editingBlowby){
            _ = model.addBlowby(blowby: newBlowBy!);
          }
            onSubmit?()
            self.remove()
            return onClick(model)
        }
    }

    /// Entry for Modal view, Sets modal to editing mode if a Blowby modal is passed in as argument, else remains in create mode.
    func initialize(shift: ShiftModel, newBlowby: BlowbyModel? = BlowbyModel(),  delegate: InputDelegate, onStart: @escaping (_ model: ShiftModel) -> Void, onCancel:  @escaping () -> Void) {
        self.onStart = onStart
        self.onCancel = onCancel
        setFixed(width: 550, height: 400);
        present();
        style();
      
        //Give the modal a refernce to the current shift, and set the Blowby
        self.model = shift;
        self.newBlowBy = newBlowby;
        self.newBlowBy!.date = self.model!.shiftStartDate;
        // since a valid modal would have a timeStamp passed in, we can determine if this is an empty model or an existing one
        self.editingBlowby = newBlowBy!.timeStamp != "";
        if(self.editingBlowby) {
          editingMode();
        }
        generateInput(delegate: delegate);
        addListeners();
        accessibilityLabel = "newShiftModal";
        accessibilityValue = "newShiftModal";
    }
  
  /// Changes Buttons in view to reflect that we are editing a modal, to help differentiate that we are not creating a modal.
  private func editingMode() {
    cancelButton.setTitle("Delete", for: .normal);
    cancelButton.removeTarget(nil, action: #selector(cancelAction(_:)), for: .touchUpInside)
    cancelButton.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside)
    cancelButton.layer.borderWidth = 1.0
    cancelButton.layer.borderColor = CGColor(red:0,green:0,blue:0,alpha:1.0);
    cancelButton.layer.backgroundColor = CGColor(red: 220/255.0, green: 53/255.0, blue: 69/255.0, alpha: 1.0)
    cancelButton.setTitleColor(UIColor.white, for: .normal)
    startNowButton.setTitle("Ok", for: .normal);
    headerLabel.text = "Edit Blowby";
  }
    
    private func addListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.inputItemValueChanged(notification:)), name: .InputItemValueChanged, object: nil)
    }
    
    // MARK: Input Item Changed
    @objc func inputItemValueChanged(notification: Notification) {
        guard let item: InputItem = notification.object as? InputItem else {return}
        // Set value in Realm object
      if(editingBlowby){
        self.newBlowBy!.editSet(value: item.value.get(type: item.type) as Any, for: item.key)
      } else {
        self.newBlowBy!.set(value: item.value.get(type: item.type) as Any, for: item.key)
      }
    }
    
    func generateInput(delegate: InputDelegate) {
        let fields = newBlowBy!.getThisBlowbyFields(editable: true, modalSize: true)
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
