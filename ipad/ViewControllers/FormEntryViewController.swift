//
//  FormEntryViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-29.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

protocol InputProtocol: class {
    func showDropdownDelegate(items: [DropdownModel], on view: UIView, callback: @escaping (_ selection: DropdownModel) -> Void)
}

class FormEntryViewController: BaseViewController, InputProtocol {
    
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Constants
    let collectionCells = [
        "DropdownCollectionViewCell"
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
            print(item.value!)
        }
    }
    
    // MARK: Delegates
    func showDropdownDelegate(items: [DropdownModel], on view: UIView, callback:  @escaping (_ selection: DropdownModel) -> Void) {
        self.showDropdown(items: items, on: view) { (result) in
            return callback(result!)
        }
    }
    
    // MARK: Temporary
    private func addTestData() {
        var options: [DropdownModel] = []
        
        options.append(DropdownModel(display: "Something here"))
        options.append(DropdownModel(display: "Something else here"))
        options.append(DropdownModel(display: "Something more here"))
        options.append(DropdownModel(display: "Another thing"))
        
        let drodownItem1 = InputItem(type: .Dropdown, key: "drodownItem1", header: "Test drop", editable: true, dropdownItems: options)
        
        let drodownItem2 = InputItem(type: .Dropdown, key: "drodownItem2", header: "Test drop 2", editable: true, width: .Half, dropdownItems: options)
        let drodownItem3 = InputItem(type: .Dropdown, key: "drodownItem3", header: "Test drop 3", editable: true, width: .Half, dropdownItems: options)
        
        let drodownItem4 = InputItem(type: .Dropdown, key: "drodownItem4", header: "Test drop 4", editable: true, width: .Third, dropdownItems: options)
        let drodownItem5 = InputItem(type: .Dropdown, key: "drodownItem5", header: "Test drop 5", editable: true, width: .Third, dropdownItems: options)
        let drodownItem6 = InputItem(type: .Dropdown, key: "drodownItem6", header: "Test drop 6", editable: true, width: .Third, dropdownItems: options)
        let drodownItem7 = InputItem(type: .Dropdown, key: "drodownItem7", header: "Test drop 7", editable: true, width: .Half, dropdownItems: options)
        let drodownItem8 = InputItem(type: .Dropdown, key: "drodownItem8", header: "Test drop 8", editable: true, width: .Third, dropdownItems: options)
        
        self.inputItems.append(drodownItem1)
        self.inputItems.append(drodownItem2)
        self.inputItems.append(drodownItem3)
        self.inputItems.append(drodownItem4)
        self.inputItems.append(drodownItem5)
        self.inputItems.append(drodownItem6)
        self.inputItems.append(drodownItem7)
        self.inputItems.append(drodownItem8)
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inputItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = getDropdownCell(indexPath: indexPath)
        cell.setup(with: inputItems[indexPath.row], delegate: self)
        return cell
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
