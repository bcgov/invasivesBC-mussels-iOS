//
//  ViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-28.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentNext()
    }
    
    private func presentNext() {
        performSegue(withIdentifier: "showHomePage", sender: nil)
        return;
//        if (!Auth.isAuthenticated()) {
//            performSegue(withIdentifier: "performLogin", sender: nil)
//            return
//        } else {
//            performSegue(withIdentifier: "showHomePage", sender: nil)
//            return
//        }
    }
}

