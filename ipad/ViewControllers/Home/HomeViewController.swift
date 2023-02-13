//
//  HomeViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-28.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit
import Reachability
//import Crashlytics

class HomeViewController: BaseViewController {
    
    // MARK: Outlets
    @IBOutlet weak var navigationBar: UIView!
    @IBOutlet weak var appTitle: UILabel!
    @IBOutlet weak var reachabilityIndicator: UIView!
    @IBOutlet weak var reachabilityLabel: UILabel!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var syncButton: UIButton!
    @IBOutlet weak var addEntryButton: UIButton!
    @IBOutlet weak var switcherHolder: UIView!
    @IBOutlet weak var tableContainer: UIView!
    @IBOutlet weak var gearButton: UIButton?
    
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
        SyncService.shared.syncIfPossible()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        endReachabilityNotification()
    }
    
    // MARK: Outlet actions
    @IBAction func userButtonAction(_ sender: Any) {
        showOptions(options: [.Logout], on: sender as! UIButton) { [weak self] (selected) in
            guard let _self = self else {return}
            Alert.show(title: StringConstants.Alerts.Logout.title, message: StringConstants.Alerts.Logout.message, yes: {
                AuthenticationService.logout()
                _self.dismiss(animated: true, completion: nil)
            }) {}
        }
    }
    
    @IBAction func syncButtonAction(_ sender: Any) {
        SyncService.shared.canSync { (syncValidation) in
            switch syncValidation {
            case .Ready:
                SyncService.shared.syncIfPossible()
            case .isOffline:
                Alert.show(title: StringConstants.Alerts.IsOffline.title, message: StringConstants.Alerts.IsOffline.message)
            case .NeedsAccess:
                Alert.show(title: StringConstants.Alerts.NeedsAccess.title, message: StringConstants.Alerts.NeedsAccess.message)
            case .AuthExpired:
                SyncService.shared.showAuthDialogAndSync()
            case .NothingToSync:
                Alert.show(title: StringConstants.Alerts.NothingToSync.title, message: StringConstants.Alerts.NothingToSync.message)
            case .SyncDisabled:
                Alert.show(title: StringConstants.Alerts.SyncIsDisabled.title, message: StringConstants.Alerts.SyncIsDisabled.message)
            }
        }
    }
    
    @IBAction func addEntryAction(_ sender: Any) {
        if let existing = getActiveShift() {
            self.navigateToShiftOverview(object: existing, editable: true)
        } else {
            let shiftModal: NewShiftModal = NewShiftModal.fromNib()
            shiftModal.initialize(delegate: self, onStart: { [weak self] (model) in
                guard let _self = self else {return}
                Storage.shared.save(shift: model)
                _self.navigateToShiftOverview(object: model, editable: true)
            }) {
                // Canceled
            }
        }
    }
    
    @IBAction func gearAction(_ sender: Any?) {
        guard let sender = sender as? UIButton else {return}
        showOptions(options: [.RefreshContent, .ReportAnIssue], on: sender) { (selectedOption) in
            switch selectedOption {
            case .ReportAnIssue:
                InfoLog("User wants to report")
                // Showing alert with input
                self.showAlert("Do you want to report an issue?", "Report", ["Message to admin"], ["Cancel", "OK"]) {[weak self] (info) in
                    if info.selectedButtonIndex == 1 {
                        InfoLog("User selects => Report")
                        let message = info.textFieldValues.count > 0 ? info.textFieldValues[0] : ""
                        self?.sendReport(message: message)
                    }
                }
            case .RefreshContent:
                SyncService.shared.syncCodeTablesAndWaterBodiesIfPossible()
            default:
                return
            }
        }
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
    
    // MARK: Initialization
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
        _ = Switcher.show(items: switcherItems, in: switcherHolder, initial: switcherItems.first) { [weak self] (selection) in
            guard let _self = self else {return}
            let shifts = Storage.shared.shifts()
            if selection.lowercased() == "all" {
                _self.createTable(with: shifts)
                return
            }
            var fileter: [ShiftModel] = []
            for shift in shifts where shift.status.lowercased() == selection.lowercased() {
                fileter.append(shift)
            }
            _self.createTable(with: fileter)
        }
    }
    
    func beginListener() {
        NotificationCenter.default.removeObserver(self, name: .TableButtonClicked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.tableButtonClicked(notification:)), name: .TableButtonClicked, object: nil)
        NotificationCenter.default.removeObserver(self, name: .syncExecuted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.syncExecuted(notification:)), name: .syncExecuted, object: nil)
        NotificationCenter.default.removeObserver(self, name: .shouldRefreshTable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.shouldRefreshTable(notification:)), name: .shouldRefreshTable, object: nil)
    }
    
    @objc func syncExecuted(notification: Notification) {
        self.initialize()
    }
    
    @objc func shouldRefreshTable(notification: Notification) {
        self.initialize()
    }
    
    // MARK: Utilities
    func getActiveShift() -> ShiftModel? {
        let existingShifts = Storage.shared.shifts(by: Date().stringShort())
        for shift in existingShifts where shift.shouldSync == false && shift.remoteId < 0 {
            return shift
        }
        return nil
    }
    
    // MARK: Feedback
    private func sendReport(message: String = "") {
        let urls = ApplicationLogger.defalutLogger.logsURLs()
        Banner.show(message: "Reporting issue ...")
        APIRequest.uploadFile(fileURL: urls[0], info: ["name": "ios_log.txt", "message": message]) { (sucess) in
            if sucess {
                InfoLog("Reporting [SUCCESS]")
                Banner.show(message: "Successfully submitted the report. System Admin will contact you as soon as possible.")
            } else {
                Banner.show(message: "Unable to submit the report, please try again later. ")
                InfoLog("Reporting FAIL")
            }
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
        let tableView = table.show(columns: columns, in: shifts, container: tableContainer, emptyTitle: "It's looking a little empty around here", emptyMessage: "You have not created any entries in the InvasivesBC app. Use the Add Entry button to create a new watercraft inspection or passport.")
        tableView.layoutIfNeeded()
        self.view.layoutIfNeeded()
        beginListener()
    }
    
    // Table Button clicked
    @objc func tableButtonClicked(notification: Notification) {
        guard let actionModel = notification.object as? TableClickActionModel, let shiftModel = actionModel.object as? ShiftModel else {return}
        if actionModel.buttonName.lowercased() == "view" {
            self.navigateToShiftOverview(object: shiftModel, editable: shiftModel.localId == getActiveShift()?.localId)
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
        userButton.setTitleColor(Colors.primary, for: .normal)
        userButton.setImage(UIImage(systemName: "person.crop.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 45, weight: .light)), for: .normal)
        userButton.tintColor = UIColor.white
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
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
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
