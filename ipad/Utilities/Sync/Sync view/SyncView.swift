//
//  SyncView.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-04.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit
import Modal
import Lottie

class SyncView: ModalView, Theme {
    
    @IBOutlet weak var syncModal: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var syncImageView: UIImageView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var statusIconView: UIImageView!
    @IBOutlet weak var hollowButton: UIButton!
    @IBOutlet weak var fillButton: UIButton!
    @IBOutlet weak var dividerView: UIView!
    
    let inProgressImageProvider = FilepathImageProvider(filepath: "ipad/ipad/Utilities/Lottie/sync-icon.json")
    
    
    let syncIconTag = 200
    let invisibleAlpha: CGFloat = 0
    let visibleAlpha: CGFloat = 1
    
    public func initialize() {
        setFixed(width: 400, height: 390)
        style()
        present()
    }
    
    @IBAction func cancelSyncAction(_ sender: Any) {
        self.remove()
    }
    
    private func style() {
        styleCard(layer: self.layer)
        styleSectionTitle(label: titleLabel)
        titleLabel.textColor = Colors.primary
        styleDivider(view: dividerView)
        styleHollowButton(button: hollowButton)
        styleFillButton(button: fillButton)
        addSyncIcon()
//        styleSyncInProgress()
//        styleSyncError()
        styleSyncSuccess()
    }
    
    private func addSyncIcon() {
        let animationView = AnimationView()
        animationView.frame = statusIconView.frame
        animationView.center.y = statusIconView.center.y
        animationView.center.x = statusIconView.center.x
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        
        statusIconView.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: statusIconView.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: statusIconView.centerYAnchor)
        ])
    }
    
    private func clearIcon() {
        for subview in statusIconView.subviews {
            subview.removeFromSuperview()
        }
    }
    
    private func styleSyncInProgress() {
//        animateSyncIcon()
        statusLabel.text = "Now syncing your data..."
        hollowButton.setTitle("Cancel Sync", for: .normal)
        fillButton.isHidden = true
        showSyncInProgressAnimation()
    }
    
    private func styleSyncSuccess() {
        statusLabel.text = "Syncing Complete"
        hollowButton.isHidden = true
        fillButton.isHidden = false
        fillButton.setTitle("Continue", for: .normal)
        showSyncCompletedAnimation()
    }
    
    private func styleSyncError() {
        statusLabel.text = "There was an error while syncing your data"
        hollowButton.setTitle("Skip for now...", for: .normal)
        fillButton.setTitle("Try again", for: .normal)
        fillButton.isHidden = false
        showSyncFailedAnimation()
    }
    
    func animateSyncIcon() {
        if let animation = self.viewWithTag(syncIconTag) as? AnimationView {
            animation.alpha = visibleAlpha
            animation.loopMode = .loop
            animation.play()
        }
    }
    
    func showSyncInProgressAnimation() {
//        clearIcon()
//        let animation = Animation.filepath("ipad/ipad/Utilities/Lottie/spinner.json")
        let animationView = AnimationView()
        animationView.imageProvider = inProgressImageProvider
//        let animationView = AnimationView(name: "spinner")
        animationView.frame = statusIconView.frame
        animationView.center.y = statusIconView.center.y
        animationView.center.x = statusIconView.center.x
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        statusIconView.addSubview(animationView)
        
        animationView.play()
    }
    
    func showSyncFailedAnimation() {
        
    }
    
    func showSyncCompletedAnimation() {
        
    }

}
