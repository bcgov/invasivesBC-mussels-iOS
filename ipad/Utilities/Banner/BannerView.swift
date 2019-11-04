//
//  BannerView.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-04.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

import UIKit

class BannerView: UIView, Theme {
    
    // MARK: Outlets
    @IBOutlet weak var label: UILabel!
    

    // MARK: Variables
    var displayDuration: TimeInterval = Banner.shared.displayDuration
    var animationDuration: TimeInterval = 0.4
    
    var dimissInitiated: Bool = false
    
    var callback: (() -> Void )?

    // MARK: Optionals
    var originY: CGFloat?
    var originX: CGFloat?

    // MARK: size
    // Note: Width is dynamic based on text size.
    var width: CGFloat = 300
    let height: CGFloat = 60

    func show(message: String, x: CGFloat , y: CGFloat , duration: TimeInterval? = 3, then: @escaping () -> Void) {
        style()
        self.callback = then
        if let duration = duration {
            self.displayDuration = duration
        }
        self.label.text = message
        self.originY = y
        self.originX = x

        self.width = message.width(withConstrainedHeight: height, font: Banner.shared.bannerTextFont()) + 30

        setupGesture()
        beginDisplayAnimation()
    }
    
    func setupGesture() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeLeft.direction = .left
        self.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeRight.direction = .right
        self.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeUp.direction = .up
        self.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleGesture(gesture:)))
        swipeDown.direction = .down
        self.addGestureRecognizer(swipeDown)
        
        self.isUserInteractionEnabled = true
    }
    
    @objc func handleGesture(gesture: UISwipeGestureRecognizer) {
  
        if gesture.direction == UISwipeGestureRecognizer.Direction.left {
            performDismissAnimation(quick: true)
        }
    }

    func beginDisplayAnimation() {
        positionPreAnimation()
        UIView.animate(withDuration: SettingsConstants.animationDuration, animations: {
            self.positionDispayed()
        }) { (done) in
            self.beginDismissAnimation()
        }
    }

    func positionDispayed() {
        guard let originY = self.originY, let originX = self.originX else {return}
        self.frame = CGRect(x: originX, y: originY, width: width, height: height)
        layoutIfNeeded()
    }

    func positionPreAnimation() {
        guard let originY = self.originY, let originX = self.originX else {return}
        self.frame = CGRect(x: (originX - width), y: originY, width: width, height: height)
        layoutIfNeeded()
    }

    func beginDismissAnimation() {
        let totalDelay = (displayDuration + animationDuration)
        DispatchQueue.main.asyncAfter(deadline: (.now() + totalDelay)) {
            self.performDismissAnimation(quick: false)
        }
    }
    
    func performDismissAnimation(quick: Bool = false) {
        if dimissInitiated {return}
        dimissInitiated = true
        var duration = SettingsConstants.shortAnimationDuration
        if quick {
            duration = duration / 2
        }
        UIView.animate(withDuration: duration, animations: {
            self.positionPreAnimation()
        }) { (done) in
            if let callback = self.callback {
                callback()
            }
            self.removeFromSuperview()
        }
    }

    func style() {
        addShadow(to: self.layer, opacity: 0.4, height: 2)
        self.label.font = Banner.shared.bannerTextFont()
        self.label.textColor = Colors.active.blue
    }
}
