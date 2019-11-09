//
//  syncBlurb.swift
//  ipad
//
//  Created by Williams, Andrea IIT:EX on 2019-11-08.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit
import Modal

class SyncBlurb: ModalView, Theme {

    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    
    public func initialize(syncState: SyncView.SyncState) {
        present()
        applyGenericStyle()
        if syncState == SyncView.SyncState.inprogress {
            styleInProgress()
        } else if syncState == SyncView.SyncState.complete {
            styleComplete()
        } else if syncState == SyncView.SyncState.error {
            styleError()
        }
    }
    
    public func applyGenericStyle() {
        styleSectionTitle(label: titleLabel)
        titleLabel.textColor = Colors.primary
        textLabel.textAlignment = .center
    }
    
    private func styleInProgress() {
        titleLabel.text = "What is syncing?"
        textLabel.text = "The app is now downloading your assigned agreements to this device.\n This lets you use the app offline (without an internet connection) while in the field or in spotty service areas."
    }
    
    private func styleComplete() {
        titleLabel.text = ""
        textLabel.text = ""
    }
    
    private func styleError() {
        titleLabel.text = "Problems while syncing?"
        textLabel.text = "If you're using cellular data try switching to a wifi connection if available.\n Syncing keeps your data safe so be sure to complete a sync at least once a week after making entries or updates offline."
    }
}
