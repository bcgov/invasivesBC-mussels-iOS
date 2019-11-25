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
    
    // MARK: Outlets
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var startNowButton: UIButton!
    @IBOutlet weak var inputContainer: UIView!
    
    
    public func initialize(onStart: @escaping () -> Void, onCancel:  @escaping () -> Void) {
        self.onStart = onStart
        self.onCancel = onCancel
        setFixed(width: 550, height: 570)
        present()
        style()
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
    
    func generateInput() {
        
    }
    
    func style() {
        styleFillButton(button: startNowButton)
        styleHollowButton(button: cancelButton)
    }
}
