//
//  Alert.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-28.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import UIKit
import Modal

class Alert {
    
    /**
     Show an alert messsage with yes / no buttons
     and return call back when user makes selection
     */
    static func show(title: String, message: String, yes: @escaping()-> Void, no: @escaping()-> Void) {
        self.showCustomAlert(title: title, message: message, yes: yes, no: no)
    }
    
    /**
     Show an alert message with an okay button
     */
    static func show(title: String, message: String) {
        ModalAlert.show(title: title, message: message)
    }
    
    /**
     Show a validation alert message for inspections
     */
    static func showValidation(title: String, message: String) {
        if let topVC = UIApplication.shared.windows.first?.rootViewController?.topMostViewController() {
            let alertVC = ScrollableAlertViewController()
            alertVC.modalPresentationStyle = .overFullScreen
            alertVC.modalTransitionStyle = .crossDissolve
            alertVC.configure(title: title, message: message)
            topVC.present(alertVC, animated: true)
        }
    }

    
    
    // MARK: Custom alerts using Modal pod
    private static func showCustomAlert(title: String, message: String, yes: @escaping()-> Void, no: @escaping()-> Void) {
        ModalAlert.show(title: title, message: message, yes: yes, no: no)
    }
        
    private static func showCustomAlert(title: String, message: String) {
         ModalAlert.show(title: title, message: message)
    }
 }
