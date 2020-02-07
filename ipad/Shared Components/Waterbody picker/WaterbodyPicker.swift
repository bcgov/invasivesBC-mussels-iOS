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

class WaterbodyPicker: UIView, Theme {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var barContainer: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var otherContainer: UIView!
    @IBOutlet weak var addManuallyButton: UIButton!
    
    // MARK: Constants
    private let tableCells = [
        "WaterbodyTableViewCell",
    ]
    
    // MARK: Variables:
    private var items: [DropdownModel] = []
    private var filteredItems: [DropdownModel] = []
    private var completion: ((_ result: DropdownModel?) -> Void )?
    
    deinit {
        print("de-init waterbodyPicker")
    }
    
    @IBAction func selectAction(_ sender: UIButton) {
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.removeFromSuperview()
    }
    
    func setup(in containerView: UIView, result: @escaping(DropdownModel?) -> Void) {
        self.completion = result
        self.loadWaterBodies()
        self.position(in: containerView)
        self.style()
        self.setUpTable()
        self.searchBar.delegate = self
        self.tableView.reloadData()
    }
    
    private func loadWaterBodies() {
        self.items = Storage.shared.getWaterBodyDropdowns()
        self.filteredItems = items
        self.otherContainer.alpha = 0
    }
    
    private func resetSearch() {
        self.filteredItems = self.items
        self.otherContainer.alpha = 0
        self.tableView.reloadData()
    }
    
    private func showOtherDialog() {
        self.filteredItems = []
        self.tableView.reloadData()
        UIView.animate(withDuration: 0.3) {
            self.otherContainer.alpha = 1
            self.layoutIfNeeded()
        }
    }
    
    private func filter(by text: String) {
        self.otherContainer.alpha = 0
        self.filteredItems = items.filter{$0.display.contains(text)}
        self.tableView.reloadData()
    }
    
    private func position(in containerView: UIView) {
        // Set initial position with 0 alpha and add as subview
        self.frame = CGRect(x: 0, y: containerView.frame.maxY, width: containerView.bounds.width, height: containerView.bounds.height)
        self.center.x = containerView.center.x
        self.alpha = 0
        containerView.addSubview(self)
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: CGFloat(0.5), options: .curveEaseInOut, animations: {
            
            self.translatesAutoresizingMaskIntoConstraints = false
            self.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0).isActive = true
            self.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0).isActive = true
            self.topAnchor.constraint(equalTo: containerView.topAnchor, constant: -20).isActive = true
            self.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true
            self.alpha = 1
            self.layoutIfNeeded()
        })
       
//        self.heightAnchor.constraint(equalTo: containerView.heightAnchor, constant: 0).isActive = true
//        self.widthAnchor.constraint(equalTo: containerView.widthAnchor, constant: 0).isActive = true
        
//        self.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 0).isActive = true
//        self.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0).isActive = true
        
    }
    
    private func returnResult(item: DropdownModel){
        guard let callback = self.completion else {return}
        return callback(item)
    }
    
    private func style() {
        self.barContainer.backgroundColor = Colors.primary
        self.backButton.setTitleColor(.white, for: .normal)
        self.selectButton.setTitleColor(.white, for: .normal)
//        self.searchBar.backgroundColor = Colors.primary
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

extension WaterbodyPicker: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count < 1 {
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


extension WaterbodyPicker: UITableViewDataSource, UITableViewDelegate {
    private func setUpTable() {
        if self.tableView == nil {return}
        tableView.delegate = self
        tableView.dataSource = self
        for cell in tableCells {
            register(cell: cell)
        }
    }
    
    func register(cell name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }
    
    func getRowCell(indexPath: IndexPath) -> WaterbodyTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "WaterbodyTableViewCell", for: indexPath) as! WaterbodyTableViewCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getRowCell(indexPath: indexPath)
        cell.setup(item: filteredItems[indexPath.row], onClick: {
            self.returnResult(item: self.filteredItems[indexPath.row])
        })
        
        return cell
    }
}
