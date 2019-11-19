//
//  HomeViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-28.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit
import Reachability

class HomeViewController: BaseViewController {

    // MARK: Outlets
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var appTitle: UILabel!
    @IBOutlet weak var reachabilityIndicator: UIView!
    @IBOutlet weak var reachabilityLabel: UILabel!
    @IBOutlet weak var lastSyncLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var syncButton: UIButton!
    @IBOutlet weak var addEntryButton: UIButton!
    @IBOutlet weak var switcherHolder: UIView!
    
    // MARK: Constants
    let switcherItems: [String] = ["All", "Drafts", "Pending Sync", "Submitted"]
    let reachability =  try! Reachability()
    
    // MARK: Variables
    
    // MARK: Computed variables
    var online: Bool = false {
        didSet {
            updateStyleAccordingToNetworkStatus()
            if (online) {
                whenOnline()
            } else {
                whenOffline()
            }
        }
    }
    
    // MARK: Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar(hidden: true, style: UIBarStyle.black)
        initirialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        endReachabilityNotification()
    }
    
    // MARK: Outlet actions
    @IBAction func userButtonAction(_ sender: Any) {
        showOptions(options: [.Logout], on: sender as! UIButton) { (selected) in
            Alert.show(title: StringConstants.Alerts.Logout.title, message: StringConstants.Alerts.Logout.message, yes: {
                Auth.logout()
                self.dismiss(animated: true, completion: nil)
            }) {}
        }
    }
    
    @IBAction func syncButtonAction(_ sender: Any) {
        let syncView: SyncView = SyncView.fromNib()
        syncView.initialize()
    }
    
    @IBAction func addEntryClicked(_ sender: Any) {
//        self.performSegue(withIdentifier: "showFormEntry", sender: self)
        self.performSegue(withIdentifier: "showShiftOverview", sender: self)
//        self.performSegue(withIdentifier: "showWatercraftInspectionForm", sender: self)
    }
    
    // MARK: Functions
    private func initirialize() {
        beginReachabilityNotification()
        style()
        setupSwitcher()
    }
    
    private func setupSwitcher() {
        _ = Switcher.show(items: switcherItems, in: switcherHolder, initial: switcherItems.first) { (selection) in
            // TODO: handle filter
            // Alert.show(title: "Selected", message: selection)
        }
    }
    
    // MARK: Style
    private func style() {
        styleNavigationBar()
        styleUserButton()
        styleSyncButton()
        styleFillButton(button: addEntryButton)
    }
    
    // Style gradiant navigation
    private func styleNavigationBar() {
        setGradiantBackground(view: navigationBar)
        setAppTitle(label: appTitle, darkBackground: true)
        styleBody(label: reachabilityLabel, darkBackground: true)
        styleBody(label: lastSyncLabel, darkBackground: true)
    }
    
    // Style network status indicators
    private func updateStyleAccordingToNetworkStatus() {
        makeCircle(view: reachabilityIndicator)
        if online {
            self.reachabilityLabel.text = "Online Mode"
            self.reachabilityIndicator.backgroundColor = UIColor.green
        } else {
            self.reachabilityLabel.text = "Offline Mode"
            self.reachabilityIndicator.backgroundColor = UIColor.red
        }
    }
    
    private func styleUserButton() {
        makeCircle(button: userButton)
        userButton.backgroundColor = UIColor.white
        userButton.setTitleColor(Colors.primary, for: .normal)
        userButton.setTitle("AB", for: .normal)
    }
    
    private func styleSyncButton() {
        syncButton.backgroundColor = .none
        syncButton.layer.cornerRadius = 18
        syncButton.layer.borderWidth = 3
        syncButton.layer.borderColor = UIColor.white.cgColor
        syncButton.setTitleColor(.white, for: .normal)
        syncButton.setTitle("Sync Now", for: .normal)
    }
    
    // MARK: Reachability
    
    // When device comes online
    private func whenOnline() {
        
    }
     
    // When device goes offline
    private func whenOffline() {
        
    }
    
    // Add listener for when recahbility status changes
    private func beginReachabilityNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .reachabilityChanged, object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            print("could not start reachability notifier")
        }
    }
    
    // Handle recahbility status change
    @objc func reachabilityChanged(note: Notification) {
        guard let reachability = note.object as? Reachability else {return}
        switch reachability.connection {
        case .wifi:
            online = true
        case .cellular:
            online = true
        case .none:
            online = false
        case .unavailable:
           online = false
        }
    }
    
    // End recahbility listener
    private func endReachabilityNotification() {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
   
}
