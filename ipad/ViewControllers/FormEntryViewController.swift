//
//  FormEntryViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-29.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

protocol InputDelegate: class {
    func showDropdownDelegate(items: [DropdownModel], on view: UIView, callback: @escaping (_ selection: DropdownModel) -> Void)
    func showDatepickerDelegate(on view: UIView, initialDate: Date?, minDate: Date?, maxDate: Date?, callback: @escaping (_ date: Date) -> Void)
}

class FormEntryViewController: BaseViewController, InputDelegate {
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Constants
    let collectionCells = [
        "TextInputCollectionViewCell",
        "DropdownCollectionViewCell",
        "SwitchInputCollectionViewCell"
    ]
    
    // MARK: Variables
    var inputItems: [InputItem] = []
    
    // MARK: View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTestData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar(hidden: false, style: UIBarStyle.default)
        setupCollectionView()
    }
    
    // MARK: Outlet actions
    @IBAction func testAction(_ sender: UIButton) {
        for item in self.inputItems {
            print(item.value.get(type: item.type) ?? "Not Set")
        }
    }
    
    // MARK: Delegates
    func showDropdownDelegate(items: [DropdownModel], on view: UIView, callback:  @escaping (_ selection: DropdownModel) -> Void) {
        self.showDropdown(items: items, on: view) { (result) in
            return callback(result!)
        }
    }
    
    func showDatepickerDelegate(on view: UIView, initialDate: Date?, minDate: Date?, maxDate: Date?, callback: @escaping (Date) -> Void) {
         
     }
    
    // MARK: Temporary
    private func addTestData() {
        var options: [DropdownModel] = []
        
        options.append(DropdownModel(display: "Something here"))
        options.append(DropdownModel(display: "Something else here"))
        options.append(DropdownModel(display: "Something more here"))
        options.append(DropdownModel(display: "Another thing"))
        
        /// Dropdowns
        let drodownItem1 = DropdownInput(key: "drodownItem1", header: "Test drop", editable: true, dropdownItems: options)
        
        let drodownItem2 = DropdownInput(key: "drodownItem2", header: "Test drop 2", editable: true, width: .Half, dropdownItems: options)
        let drodownItem3 = DropdownInput(key: "drodownItem3", header: "Test drop 3", editable: true, width: .Half, dropdownItems: options)
        
        let drodownItem4 = DropdownInput(key: "drodownItem4", header: "Test drop 4", editable: true, width: .Third, dropdownItems: options)
        let drodownItem5 = DropdownInput(key: "drodownItem5", header: "Test drop 5", editable: true, width: .Third, dropdownItems: options)
        let drodownItem6 = DropdownInput(key: "drodownItem6", header: "Test drop 6", editable: true, width: .Third, dropdownItems: options)
        let drodownItem7 = DropdownInput(key: "drodownItem7", header: "Test drop 7", editable: true, width: .Half, dropdownItems: options)
        let drodownItem8 = DropdownInput(key: "drodownItem8", header: "Test drop 8", editable: true, width: .Third, dropdownItems: options)
        
        /// Text Input
        let textInput1 = TextInput(key: "input1", header: "input 1", editable: true, width: .Half)
        let textInput2 = TextInput(key: "input2", header: "input 2", editable: true, width: .Half)
        
        let textInput3 = TextInput(key: "input3", header: "input 3", editable: true, width: .Third)
        let textInput4 = TextInput(key: "input4", header: "input 4", editable: true, width: .Third)
        let textInput5 = TextInput(key: "input5", header: "input 5", editable: true, width: .Third)
        
        /// Switch
        let switch1 =  SwitchInput(key: "switch1", header: "Switch 1", editable: true, value: true, width: .Forth)
        let switch2 =  SwitchInput(key: "switch2", header: "Switch 2", editable: true, width: .Forth)
        let switch3 =  SwitchInput(key: "switch3", header: "Switch 3", editable: true, width: .Forth)
        let switch4 =  SwitchInput(key: "switch4", header: "Switch 4", editable: true, width: .Forth)
        
        self.inputItems.append(drodownItem1)
        self.inputItems.append(drodownItem2)
        self.inputItems.append(drodownItem3)
        self.inputItems.append(drodownItem4)
        self.inputItems.append(drodownItem5)
        self.inputItems.append(drodownItem6)
        self.inputItems.append(drodownItem7)
        self.inputItems.append(drodownItem8)
        
        self.inputItems.append(textInput5)
        self.inputItems.append(textInput4)
        self.inputItems.append(textInput3)
        self.inputItems.append(textInput2)
        self.inputItems.append(textInput1)
        
        self.inputItems.append(switch1)
        self.inputItems.append(switch2)
        self.inputItems.append(switch3)
        self.inputItems.append(switch4)
    }
    
}

extension FormEntryViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private func setupCollectionView() {
        for cell in collectionCells {
            register(cell: cell)
        }
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func register(cell name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: name)
    }
    
    func getDropdownCell(indexPath: IndexPath) -> DropdownCollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "DropdownCollectionViewCell", for: indexPath as IndexPath) as! DropdownCollectionViewCell
    }
    
    func getTextInputCell(indexPath: IndexPath) -> TextInputCollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "TextInputCollectionViewCell", for: indexPath as IndexPath) as! TextInputCollectionViewCell
    }
    
    func getSwitchInputCell(indexPath: IndexPath) -> SwitchInputCollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "SwitchInputCollectionViewCell", for: indexPath as IndexPath) as! SwitchInputCollectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inputItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = inputItems[indexPath.row]
        switch item.type {
        case .Dropdown:
            let cell = getDropdownCell(indexPath: indexPath)
            cell.setup(with: item as! DropdownInput, delegate: self)
            return cell
        case .Text:
            let cell = getTextInputCell(indexPath: indexPath)
            cell.setup(with: item as! TextInput, delegate: self)
            return cell
        case .Int:
            let cell = getTextInputCell(indexPath: indexPath)
            cell.setup(with: item as! TextInput, delegate: self)
            return cell
        case .Double:
            let cell = getTextInputCell(indexPath: indexPath)
            cell.setup(with: item as! TextInput, delegate: self)
            return cell
        case .Date:
            let cell = getTextInputCell(indexPath: indexPath)
            cell.setup(with: item as! TextInput, delegate: self)
            return cell
        case .Switch:
            let cell = getSwitchInputCell(indexPath: indexPath)
            cell.setup(with: item as! SwitchInput, delegate: self)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let assumedCellSpacing: CGFloat = 10
        var cellSpacing = assumedCellSpacing
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        if let layoutUnwrapped = layout {
            cellSpacing = layoutUnwrapped.minimumInteritemSpacing
        }
        
        let item = inputItems[indexPath.row]
        let containerWidth = collectionView.frame.width
        var multiplier: CGFloat = 1
        switch item.width {
        case .Full:
//            multiplier = 1
            return CGSize(width: containerWidth, height: item.height)
        case .Half:
            multiplier = 2
        case .Third:
            multiplier = 3
        case .Forth:
            multiplier = 4
        }
    
        return CGSize(width: (containerWidth - (multiplier * cellSpacing)) / multiplier, height: item.height)
    }
    
}
