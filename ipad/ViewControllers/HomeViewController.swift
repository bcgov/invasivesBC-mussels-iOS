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
    @IBOutlet weak var tableContainer: UIView!
    
    // MARK: Constants
    let switcherItems: [String] = ["All", "Pending Sync", "Submitted"]
    let reachability =  try! Reachability()
    
    // MARK: Variables
    var shiftModel: ShiftModel? = nil
    
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
        style()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initialize()
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
        if !AutoSync.shared.shouldSync() {
            Alert.show(title: "Nothing to sync", message: "There is nothing to sync")
        } else {
            AutoSync.shared.sync()
        }
    }
    
    @IBAction func addEntryClicked(_ sender: Any) {
        
        let waterBodyPicker: WaterbodyPicker = UIView.fromNib()
        waterBodyPicker.setup(in: self.view) { (result) in
            print(result)
        }
        return
        if let existing = getActiveShift() {
            self.navigateToShiftOverview(object: existing, editable: true)
        } else {
            let shiftModal: NewShiftModal = NewShiftModal.fromNib()
            shiftModal.initialize(delegate: self, onStart: { (model) in
                Storage.shared.save(shift: model)
                self.navigateToShiftOverview(object: model, editable: true)
            }) {
                print("cancelled")
            }
        }
    }
    
    func getActiveShift() -> ShiftModel? {
        let existingShifts = Storage.shared.shifts(by: Date().stringShort())
        for shift in existingShifts where shift.shouldSync == false && shift.remoteId < 0 {
            return shift
        }
        return nil
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let shiftOverviewVC = segue.destination as? ShiftViewController, let shiftModel = self.shiftModel {
            shiftOverviewVC.setup(model: shiftModel)
        }
    }
    
    private func navigateToShiftOverview(object: ShiftModel, editable: Bool) {
        self.shiftModel = object
        self.performSegue(withIdentifier: "showShiftOverview", sender: self)
    }
    
    // MARK: Functions
    private func initialize() {
        let shifts = Storage.shared.shifts()
        beginReachabilityNotification()
        style()
        setupSwitcher()
        createTable(with: shifts)
    }
    
    private func setupSwitcher() {
        for subview in switcherHolder.subviews {
            subview.removeFromSuperview()
        }
        _ = Switcher.show(items: switcherItems, in: switcherHolder, initial: switcherItems.first) { (selection) in
            let shifts = Storage.shared.shifts()
            if selection.lowercased() == "all" {
                self.createTable(with: shifts)
                return
            }
            var fileter: [ShiftModel] = []
            for shift in shifts where shift.status.lowercased() == selection.lowercased() {
                fileter.append(shift)
            }
            self.createTable(with: fileter)
        }
    }
    
    // MARK: Table
    func createTable(with shifts: [ShiftModel]) {
        for view in self.tableContainer.subviews {
            view.removeFromSuperview()
        }
        self.view.layoutIfNeeded()
        let table = Table()
        
        // Create Column Config
        var columns: [TableViewColumnConfig] = []
        columns.append(TableViewColumnConfig(key: "remoteId", header: "Shift ID", type: .Normal))
        columns.append(TableViewColumnConfig(key: "formattedDate", header: "Shift Date", type: .Normal))
        columns.append(TableViewColumnConfig(key: "station", header: "Station Location", type: .Normal))
        columns.append(TableViewColumnConfig(key: "status", header: "Status", type: .WithIcon))
        columns.append(TableViewColumnConfig(key: "", header: "Actions", type: .Button, buttonName: "View", showHeader: false))
        let tableView = table.show(columns: columns, in: shifts, container: tableContainer)
        tableView.layoutIfNeeded()
        self.view.layoutIfNeeded()
        beginListener()
    }
    
    // Listener for Table button action
    func beginListener() {
        NotificationCenter.default.removeObserver(self, name: .TableButtonClicked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.tableButtonClicked(notification:)), name: .TableButtonClicked, object: nil)
        NotificationCenter.default.removeObserver(self, name: .syncExecuted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.syncExecuted(notification:)), name: .syncExecuted, object: nil)
        
    }
    
    // Table Button clicked
    @objc func tableButtonClicked(notification: Notification) {
        guard let actionModel = notification.object as? TableClickActionModel, let shiftModel = actionModel.object as? ShiftModel else {return}
        if actionModel.buttonName.lowercased() == "view" {
            self.navigateToShiftOverview(object: shiftModel, editable: shiftModel.localId == getActiveShift()?.localId)
        }
    }
    
    @objc func syncExecuted(notification: Notification) {
        self.initialize()
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
