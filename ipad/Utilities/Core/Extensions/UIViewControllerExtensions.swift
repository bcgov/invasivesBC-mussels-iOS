//
//  UIViewControllerExtensions.swift
//  ipad
//
//  Created by Pushan  on 2020-03-29.
//  Copyright © 2020 Amir Shayegh. All rights reserved.
//

import Foundation
import UIKit

struct AlertActionInfo {
    var textFieldValues: [String] = [String]()
    var selectedButtonIndex: Int = -1
    var alert: UIAlertController?
}

typealias AlertAction = (_ info: AlertActionInfo) -> Void

extension UIViewController {
    @discardableResult
    class func alert(message: String, title: String = AppFullName, titles: [String],_ action: IndexAction?) -> UIAlertController {
        var localTitles: [String] = titles
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let createAction: (_ index: Int,_ isCancel: Bool) -> Void = { (index: Int, isCancel: Bool) in
            if titles.count > index {
                var style: UIAlertAction.Style = .default
                if isCancel {
                    style = .cancel
                }
                let title = localTitles[index]
                alert.addAction(UIAlertAction(title: title, style: style, handler: { (_) in
                    action?(index)
                }))
            }
        }
        if localTitles.count == 0 {
            localTitles.append("OK")
        }
        
        if localTitles.count == 1 {
            createAction(0, true)
        }
        else {
            let count = localTitles.count
            for index in 0 ..< count {
                var isCancel = false
                if index == count - 1 {
                    isCancel = true
                }
                
                createAction(index, isCancel)
            }
        }
        
        return alert
        
    }
    
    @discardableResult
    func showAlert(message: String, title: String = AppFullName, titles: [String],_ action: IndexAction?) -> UIAlertController {
        let alert = UIViewController.alert(message: message, title: title, titles: titles, action)
        self.present(alert, animated: true, completion: nil)
        return alert
    }
    
    func showAlert(message: String, title: String)  {
        let alert = UIViewController.alert(message: message, title: title, titles: ["OK"], nil)
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    func showNetworkAlert() {
        self.showAlert("The device is offline, please check your internet connection")
    }
}

extension UIViewController {
    @discardableResult
    func showAlert(_ message: String, title: String = AppFullName) -> UIAlertController? {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true) {}
        return alert
    }
    
    @discardableResult
    func showAlert(_ message: String,_ title: String = AppFullName,_ textFields: [String] = [],_ buttons: [String],action: AlertAction?) -> UIAlertController?  {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if textFields.count > 0 {
            for txt in textFields {
                alert.addTextField(configurationHandler: { (textField: UITextField) in
                    textField.placeholder = txt
                    if txt.caseInsensitiveCompare("password") == .orderedSame || txt.caseInsensitiveCompare("pwd") == .orderedSame {
                        textField.isSecureTextEntry = true
                    }
                    
                    if txt.caseInsensitiveMembership(["email", "email address", "mailto"]) {
                        textField.keyboardType = .emailAddress
                    }
                    
                    if txt.caseInsensitiveMembership(["phone", "phone number", "mobile", "mobile number"]) {
                        textField.keyboardType = .phonePad
                    }
                })
            }
        }
        
        let finalCall: (_ index: Int) -> Void  =  {(index: Int) in
            var fields: [String] = [String]()
            if let txtFields: [UITextField] = alert.textFields {
                for field in txtFields {
                    fields.append(field.text ?? "")
                }
            }
            
            let info: AlertActionInfo = AlertActionInfo(textFieldValues: fields, selectedButtonIndex: index, alert: alert)
            action?(info)
        }
        
        if buttons.count > 0 {
            var index: Int = 0;
            var indexMap: [String : Int] = [String : Int]()
            for button in buttons {
                indexMap[button] = index
                alert.addAction(UIAlertAction(title: button, style: .default, handler: { (actionObj) in
                    let title = actionObj.title ?? ""
                    if let index = indexMap[title] {
                        finalCall(index)
                    }
                    else {
                        InfoLog("No Index found")
                        finalCall(-1)
                    }
                }))
                index += 1
            }
        } else {
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                finalCall(0)
            }))
        }
        
        self.present(alert, animated: true, completion: nil)
        return alert
    }
}

extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController() ?? navigation
        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        
        return self
    }
}
