//
//  DropdownViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-29.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class DropdownViewController: UIViewController, Theme {
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var selectButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    
    // MARK: Constants
    let cellHeight: CGFloat = 33
    let buttonHeightConstant: CGFloat = 42
    let headerHeightConstant: CGFloat = 35
    let dropdownCellName = "DropdownTableViewCell"
    
    // MARK: Variables
    var parentVC: BaseViewController?
    var objects: [DropdownModel] = [DropdownModel]()
    var completion: ((_ result: DropdownModel?) -> Void )?
    var multiCompletion: ((_ done: Bool,_ result: [DropdownModel]?) -> Void )?
    var liveMultiCompletion: ((_ result: [DropdownModel]?) -> Void )?
    var multiSelect: Bool = false
    var liveMultiSelect: Bool = false
    var selectedIndexes: [Int] = [Int]()
    
    var headerTxt: String = ""
    
    var otherText: String = ""
    var otherEnabled: Bool = true
    
    // MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        style()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Outlet Actions
    @IBAction func closeAction(_ sender: Any) {
        if let callback = completion {
            return callback(nil)
        }
    }
    
    @IBAction func selectAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            self.sendBack()
        })
    }
    
    func sendBack() {
        var selected = [DropdownModel]()
        for i in selectedIndexes {
            if objects[i].key.lowercased() == "other", !otherText.isEmpty {
                selected.append(DropdownModel(display: otherText))
            } else {
                selected.append(objects[i])
            }
        }
        if multiSelect, let callback = multiCompletion {
            return callback(true, selected)
        } else if liveMultiSelect, let liveCallBack = liveMultiCompletion {
            liveCallBack(selected)
        }
    }
    
    // MARK: Functions
    // MARK: Setup
    func setup(header: String? = "", objects: [DropdownModel], onButton: UIButton, otherEnabled: Bool, completion: @escaping (_ result: DropdownModel?) -> Void) -> PopoverSize {
        self.completion = completion
        self.objects = objects
        self.headerTxt = header ?? ""
        self.otherEnabled = otherEnabled
        setupTable()
        return PopoverSize(width: Double(getEstimatedWidth()), height: Double(getEstimatedHeight()))
    }
    
    func setupMultiSelect(header: String? = "", selectedItems: [DropdownModel], items: [DropdownModel], otherEnabled: Bool, completion: @escaping (_ done: Bool,_ result: [DropdownModel]?) -> Void) -> PopoverSize {
        self.multiSelect = true
        self.multiCompletion = completion
        self.objects = items
        self.otherEnabled = otherEnabled
        
        // find already selected indexes
        for (index,element) in objects.enumerated() {
            for item in selectedItems where element.key == item.key {
                selectedIndexes.append(index)
            }
        }
        self.headerTxt = header ?? ""
        setupTable()
        return PopoverSize(width: Double(getEstimatedWidth()), height: Double(getEstimatedHeight()))
    }
    
    func setupMultiSelectLive(header: String? = "", selectedItems: [DropdownModel], items: [DropdownModel], otherEnabled: Bool, completion: @escaping (_ result: [DropdownModel]?) -> Void) -> PopoverSize {
        self.liveMultiSelect = true
        self.liveMultiCompletion = completion
        self.objects = items
        
        // find already selected indexes
        for (index,element) in objects.enumerated() {
            for item in selectedItems where element.key == item.key {
                selectedIndexes.append(index)
            }
        }
        self.headerTxt = header ?? ""
        setupTable()
        
        return PopoverSize(width: Double(getEstimatedWidth()), height: Double(getEstimatedHeight()))
    }
    
    func getEstimatedHeight() -> Int {
        // top and bottom padding in cell
        let padding = 20
        if objects.count == 0 {return padding}
        var total = (objects.count * Int(cellHeight)) + (objects.count * padding)
        if multiSelect {
            // add button height
            total += Int(buttonHeightConstant)
        }
        if liveMultiSelect {
            // add header height
            total += Int(headerHeightConstant)
        }
        return total
    }
    
    func getEstimatedWidth() -> Int {
        var max: CGFloat = 0
        if headerTxt.count > 0 {
            max = headerTxt.width(withConstrainedHeight: headerHeightConstant, font: getSubHeaderFont())
        }
        for element in objects {
            let w = element.display.width(withConstrainedHeight: cellHeight, font: Fonts.getPrimary(size: 17))
            if w > max {
                max = w
            }
        }
        // 20 is the leading + trailing of cell
        var padding: CGFloat = 20.0
        if liveMultiSelect || multiSelect {
            padding += 32.0
        }
        return Int((max + padding))
    }
    
    func canDisplayFullContentIn(height: Int) -> Bool {
        return getEstimatedHeight() <= height
    }
    
    // MARK: Style
    func style() {
        guard let btnHeight = selectButtonHeight else {return}
        if multiSelect {
            btnHeight.constant = buttonHeightConstant
            styleFillButton(button: selectButton)
        } else {
            btnHeight.constant = 0
            selectButton.alpha = 0
        }
        if headerTxt.count > 0 {
            self.header.text = headerTxt
            styleSubHeader(label: header)
            headerHeight.constant = headerHeightConstant
        } else {
            headerHeight.constant = 0
        }
    }
}

// MARK: TableView
extension DropdownViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTable() {
        if self.tableView == nil {return}
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: dropdownCellName)
    }
    
    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }
    
    func getCell(indexPath: IndexPath) -> DropdownTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: dropdownCellName, for: indexPath) as! DropdownTableViewCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var color = Colors.oddCell
        if indexPath.row % 2 == 0 {
            color = Colors.evenCell
        }
        let cell = getCell(indexPath: indexPath)
        cell.setup(object: objects[indexPath.row], bg: color)
        // if element should be selected
        if multiSelect || liveMultiSelect {
            if selectedIndexes.contains(indexPath.row) {
                cell.select()
            } else {
                cell.deSelect()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // if multi select is not enabled, return selection
        if !multiSelect && !liveMultiSelect {
            handleSingleSelection(at: indexPath.row)
        } else {
            handleMultiSelectSelection(at: indexPath.row)
        }
    }
    
    func handleSingleSelection(at row: Int) {
        guard let callback = completion else {return}
        if objects[row].key.lowercased() == "other", otherEnabled {
            // Prompt input
            let inputModal: InputModal = UIView.fromNib()
            inputModal.initialize(header: "Other") { (name) in
                if name != "" {
                    self.dismiss(animated: true) {
                        return callback(DropdownModel(display: name, key: self.objects[row].key))
                    }
                }
            }
        } else {
            self.dismiss(animated: true) {
                return callback(self.objects[row])
            }
        }
    }
    
    func handleMultiSelectSelection(at row: Int) {
        // if is already selected
        if selectedIndexes.contains(row) {
            // deselect
            guard let index = selectedIndexes.firstIndex(of: row) else {return}
            selectedIndexes.remove(at: index)
            if objects[row].key.lowercased() == "other", otherEnabled {
                self.objects[row].display = "Other"
                self.otherText = ""
            }
        } else {
            if objects[row].key.lowercased() != "other" {
                // select
                selectedIndexes.append(row)
            } else if objects[row].key.lowercased() == "other", otherEnabled {
                // handle dialog
                showOtherOption { (customText) in
                    if !customText.isEmpty {
                        self.otherText = customText
                        self.objects[row].display = customText
                        self.selectedIndexes.append(row)
                    } else {
                        self.objects[row].display = "Other"
                        self.otherText = ""
                    }
                    self.tableView.reloadData()
                    if self.liveMultiSelect {
                        self.sendBack()
                    }
                }
            } else {
                // select
                 selectedIndexes.append(row)
            }
        }
        self.tableView.reloadData()
        if liveMultiSelect {
            sendBack()
        }
    }
    
    
    func showOtherOption(completion: @escaping(_ text: String) -> Void) {
        // Prompt input
        let inputModal: InputModal = UIView.fromNib()
        inputModal.initialize(header: "Other") { (name) in
            return completion(name)
        }
    }
}
