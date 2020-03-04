//
//  WaterbodyPicker.swift
//  ipad
//
//  Created by Amir Shayegh on 2020-02-06.
//  Copyright © 2020 Amir Shayegh. All rights reserved.
//

import Foundation
import UIKit

extension UISearchBar
{
    func setPlaceholderTextColorTo(color: UIColor)
    {
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = color
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = color
    }
    
    func setMagnifyingGlassColorTo(color: UIColor)
    {
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = color
    }
}

private enum contraintType {
    case top
    case bottom
    case centerX
    case centerY
    case leading
    case trailing
    case height
}

class WaterbodyPicker: UIView, Theme {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var barContainer: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var otherContainer: UIView!
    @IBOutlet weak var addManuallyButton: UIButton!
    @IBOutlet weak var selectionsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var manualLocationField: UITextField!
    
    // MARK: Constants
    private let tableCells = [
        "WaterbodyTableViewCell",
    ]
    
    private let collectionCells = [
        "SelectedWaterBodyCollectionViewCell",
    ]
    
    // MARK: Variables:
    private var items: [DropdownModel] = []
    private var filteredItems: [DropdownModel] = []
    private var completion: ((_ result: [WaterBodyTableModel]) -> Void )?
    private var selections: [DropdownModel] = []
    private var viewConstraints: [contraintType : NSLayoutConstraint] = [contraintType : NSLayoutConstraint]()
    private var manualFields: [String] = []
    
    deinit {
        print("de-init waterbodyPicker")
    }
    
    @IBAction func selectAction(_ sender: UIButton) {
        dismissWithAnimation()
        returnResult()
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        guard let callback = self.completion else {return}
        dismissWithAnimation()
        callback([])
    }
    
    private func dismissWithAnimation() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
            self.layoutIfNeeded()
        }) { (done) in
            self.removeFromSuperview()
        }
    }
    
    @IBAction func manualLocationChanged(_ sender: UITextField) {
        
    }
    
    @IBAction func addLocationManually(_ sender: UIButton) {
        guard let text = manualLocationField.text, !text.isEmpty else {return}
        selections.append(DropdownModel(display: text, key: text))
        manualFields.append(text)
        self.showOrHideSelectionsIfNeeded()
        self.collectionView.reloadData()
        manualLocationField.text?.removeAll()
    }
    
    /**
     Displays Wateroicker in Container and returns DropdownModel Result
     */
    func setup(result: @escaping([WaterBodyTableModel]) -> Void) {
        self.completion = result
        self.loadWaterBodies()
        self.position()
        self.style()
        self.setUpTable()
        self.setupCollectionView()
        self.searchBar.delegate = self
        self.tableView.reloadData()
        self.selectionsHeightConstraint.constant = 0
        self.selectButton.isEnabled = !self.selections.isEmpty
    }
    
    // Return Results
    private func returnResult() {
        guard let callback = self.completion else {return}
        var results: [WaterBodyTableModel] = []
        for selection in selections {
            if let id = Int(selection.key), let model = Storage.shared.getWaterbodyModel(withId: id) {
                results.append(model)
            } else {
                let customWaterBody = WaterBodyTableModel()
                customWaterBody.other = selection.display
                results.append(customWaterBody)
            }
        }
        return callback(results)
    }
    
    private func selected(item: DropdownModel) {
        if indexOf(selection: item) != nil {
            remove(item: item)
        } else {
            add(item: item)
        }
    }
    
    private func add(item: DropdownModel) {
        if indexOf(selection: item) != nil {return}
        selections.append(item)
        self.showOrHideSelectionsIfNeeded()
        self.collectionView.reloadData()
    }
    
    private func remove(item: DropdownModel) {
        guard let index = indexOf(selection: item) else {return}
        self.selections.remove(at: index)
        self.showOrHideSelectionsIfNeeded()
        self.collectionView.reloadData()
        self.tableView.reloadData()
    }
    
    private func showOrHideSelectionsIfNeeded() {
        let selectTitle = !selections.isEmpty ? "Select (\(selections.count))" : "Select"
        self.selectButton.setTitle(selectTitle, for: .normal)
        self.selectButton.isEnabled = !selections.isEmpty
        UIView.animate(withDuration: 0.3) {
            self.selectionsHeightConstraint.constant = !self.selections.isEmpty ? 60 : 0
            self.collectionView.alpha = !self.selections.isEmpty ? 1 : 0
            self.layoutIfNeeded()
        }
    }
    
    private func indexOf(selection: DropdownModel) -> Int? {
        for (index, value) in selections.enumerated() where selection.display == value.display && selection.key == value.key {
            return index
        }
        return nil
    }
    
    // Load all waterbodies from storage
    private func loadWaterBodies() {
        self.items = Storage.shared.getWaterBodyDropdowns()
        self.filteredItems = items
        self.otherContainer.alpha = 0
        self.tableView.alpha = 1
    }
    
    // Reset results to show all water bodies
    private func resetSearch() {
        self.filteredItems = self.items
        UIView.animate(withDuration: 0.3) {
            self.tableView.alpha = 1
            self.otherContainer.alpha = 0
            self.layoutIfNeeded()
        }
        self.tableView.reloadData()
    }
    
    // When user enters 'Other'
    private func showOtherDialog() {
        self.filteredItems = []
        self.tableView.reloadData()
        self.searchBar.resignFirstResponder()
        UIView.animate(withDuration: 0.3) {
            self.otherContainer.alpha = 1
            self.tableView.alpha = 0
            self.layoutIfNeeded()
        }
    }
    
    // Filter Reaults
    private func filter(by text: String) {
        self.otherContainer.alpha = 0
        self.filteredItems = items.filter{$0.display.lowercased().contains(text.lowercased())}.sorted(by: { (first, second) -> Bool in
            return first.display.lowercased() < second.display.lowercased()
        })
        self.tableView.reloadData()
    }
    
    private func position() {
        guard let window = UIApplication.shared.connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first else {return}
        // Set initial position with 0 alpha and add as subview
        self.frame = CGRect(x: 0, y: window.frame.maxY, width: window.bounds.width, height: window.bounds.height)
        self.center.x = window.center.x
        self.alpha = 0
        window.addSubview(self)
        window.layoutIfNeeded()
        // Animate setting alpha to 1 and adding constraints to equal container's
        createConstraints()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        viewConstraints[.leading]?.isActive = true
        viewConstraints[.trailing]?.isActive = true
        viewConstraints[.height]?.isActive = true
        viewConstraints[.centerY]?.constant = window.frame.height
        viewConstraints[.centerY]?.isActive = true
        window.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: CGFloat(0.5), options: .curveEaseInOut, animations: {
            self.alpha = 1
            // 28 is so that it covers the status bar as well
            self.viewConstraints[.centerY]?.constant = -20
            window.layoutIfNeeded()
        }) { (done) in
            UIView.animate(withDuration: 0.1) {
                self.viewConstraints[.centerY]?.isActive = false
                self.viewConstraints[.height]?.isActive = false
                self.viewConstraints[.bottom]?.isActive = true
                self.viewConstraints[.top]?.isActive = true
                window.layoutIfNeeded()
            }
        }
    }
    
    private func createConstraints() {
        guard let window = UIApplication.shared.connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first else {return}
        viewConstraints[.trailing] = self.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: 0)
        viewConstraints[.leading] = self.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 0)
        viewConstraints[.centerY] = self.centerYAnchor.constraint(equalTo: window.centerYAnchor, constant: 0)
        viewConstraints[.centerX] = self.centerXAnchor.constraint(equalTo: window.centerXAnchor, constant: 0)
        viewConstraints[.height] = self.heightAnchor.constraint(equalTo: window.heightAnchor, constant: 0)
        viewConstraints[.top] = self.topAnchor.constraint(equalTo: window.topAnchor, constant: -20)
        viewConstraints[.bottom] = self.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: 0)
    }
    
    private func style() {
        self.barContainer.backgroundColor = Colors.primary
        self.backButton.setTitleColor(.white, for: .normal)
        self.selectButton.setTitleColor(.white, for: .normal)
        self.searchBar.barTintColor = Colors.primary
        self.titleLabel.textColor = UIColor.white
        searchBar.setPlaceholderTextColorTo(color: .white)
        searchBar.setMagnifyingGlassColorTo(color: .white)
        let attributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)
        ]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        
        styleFillButton(button: addManuallyButton)
    }
}

// MARK: Search Bar Delegate
extension WaterbodyPicker: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.resetSearch()
            return
        }
        if searchText.lowercased() == "other" {
            self.showOtherDialog()
            return
        }
        
        self.filter(by: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {}
}

// MARK: TableView
extension WaterbodyPicker: UITableViewDataSource, UITableViewDelegate {
    private func setUpTable() {
        if self.tableView == nil {return}
        tableView.delegate = self
        tableView.dataSource = self
        for cell in tableCells {
            register(table: cell)
        }
    }
    
    func register(table cellName: String) {
        let nib = UINib(nibName: cellName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellName)
    }
    
    func getRowCell(indexPath: IndexPath) -> WaterbodyTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "WaterbodyTableViewCell", for: indexPath) as! WaterbodyTableViewCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getRowCell(indexPath: indexPath)
        cell.setup(item: filteredItems[indexPath.row], optionSelected: self.indexOf(selection: filteredItems[indexPath.row]) != nil, onClick: {
            self.selected(item: self.filteredItems[indexPath.row])
        })
        
        return cell
    }
}

// MARK: CollectionView
extension WaterbodyPicker: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private func setupCollectionView() {
        guard let collectionView = self.collectionView else {return}
        for cell in collectionCells {
            register(collection: cell)
        }
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func register(collection cellName: String) {
        guard let collectionView = self.collectionView else {return}
        let nib = UINib(nibName: cellName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: cellName)
    }
    
    func getSelectedCell(indexPath: IndexPath) -> SelectedWaterBodyCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "SelectedWaterBodyCollectionViewCell", for: indexPath as IndexPath) as! SelectedWaterBodyCollectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = getSelectedCell(indexPath: indexPath)
        cell.setup(item: selections[indexPath.row]) {
            self.remove(item: self.selections[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = selections[indexPath.row]
        let textWidth = item.display.width(withConstrainedHeight: self.collectionView.bounds.height, font: Fonts.getPrimary(size: 17))
        let buttonWidth: CGFloat = 35
        let padding: CGFloat = 32
        return CGSize(width: textWidth + buttonWidth + padding, height: 60)
    }
    
}
