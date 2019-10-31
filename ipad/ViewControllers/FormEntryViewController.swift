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
        let drodownItem2 = InputItem(type: .Dropdown, key: "drodownItem2", header: "Test drop 2", editable: true, dropdownItems: options)
        
        self.inputItems.append(drodownItem1)
        self.inputItems.append(drodownItem2)
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
        let item = inputItems[indexPath.row]
        switch item.width {
        case .Full:
            return CGSize(width: collectionView.frame.width, height: item.height)
        case .Half:
            return CGSize(width: collectionView.frame.width / 2, height: item.height)
        case .Third:
            return CGSize(width: collectionView.frame.width / 3, height: item.height)
        case .Forth:
            return CGSize(width: collectionView.frame.width / 4, height: item.height)
        }
    }
    
}
