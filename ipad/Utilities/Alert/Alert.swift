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
        //self.showDefaultAlert(title: title, message: message, yes: yes, no: no)
        self.showCustomAlert(title: title, message: message, yes: yes, no: no);
    }
    
    /**
     Show an alert message with an okay button
     */
    static func show(title: String, message: String) {
        //self.showDefaultAlert(title: title, message: message)
        self.showCustomAlert(title: title, message: message);
    }
    
    // MARK: Default iOS alerts
    private static func showDefaultAlert(title: String, message: String, yes: @escaping()-> Void, no: @escaping()-> Void) {
        DispatchQueue.main.async(execute: {
            let alertWindow = UIWindow(frame: UIScreen.main.bounds)
            alertWindow.rootViewController = UIViewController()
            alertWindow.windowLevel = UIWindow.Level.alert + 1

            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { action in
                return yes();
            }))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: { action in
                return no();
            }))
            
            alertWindow.makeKeyAndVisible()
            alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
        })
    }
    
    private static func showDefaultAlert(title: String, message: String) {
        DispatchQueue.main.async(execute: {
            let alertWindow = UIWindow(frame: UIScreen.main.bounds)
            alertWindow.rootViewController = UIViewController()
            alertWindow.windowLevel = UIWindow.Level.alert + 1

            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let defaultAction2 = UIAlertAction(title: "OK", style: .default, handler: { action in
            })
            alert.addAction(defaultAction2)

            alertWindow.makeKeyAndVisible()
            alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
        })
    }
    
    // MARK: Custom alerts using Modal pod
    private static func showCustomAlert(title: String, message: String, yes: @escaping()-> Void, no: @escaping()-> Void) {
        ModalAlert.show(title: title, message: message, yes: yes, no: no);
    }
        
    private static func showCustomAlert(title: String, message: String) {
         ModalAlert.show(title: title, message: message)
    }
 }
