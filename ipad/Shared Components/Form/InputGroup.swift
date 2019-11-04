//
//  InputGroup.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-03.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class InputGroup: UIView {
    
    // MARK: Constants
    private let collectionCells = [
        "TextInputCollectionViewCell",
        "DropdownCollectionViewCell",
        "SwitchInputCollectionViewCell",
        "DateInputCollectionViewCell"
    ]
    
    // MARK: Variables
    private weak var collectionView: UICollectionView? = nil
    private var inputDelegate: InputDelegate? = nil
    private var inputItems: [InputItem] = []
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    public func initialize(with Items: [InputItem], delegate: InputDelegate) {
        self.inputItems = Items
        self.inputDelegate = delegate
        self.createCollectionView()
        self.setupCollectionView()
    }
    
    private func createCollectionView() {
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.frame.height, height: self.frame.height))
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = UIColor.darkGray
        collection.isScrollEnabled = true
        self.collectionView = collection
        addCollectionVIewConstraints()
    }
    
    private func addCollectionVIewConstraints() {
        guard let collection = self.collectionView else {return}
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.heightAnchor.constraint(equalToConstant: self.frame.height).isActive = true
        collection.widthAnchor.constraint(equalToConstant: self.frame.width).isActive = true
        collection.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        collection.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
}
extension InputGroup: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private func setupCollectionView() {
        guard let collectionView = self.collectionView else {return}
        for cell in collectionCells {
            register(cell: cell)
        }
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func register(cell name: String) {
        guard let collectionView = self.collectionView else {return}
        let nib = UINib(nibName: name, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: name)
    }
    
    func getDropdownCell(indexPath: IndexPath) -> DropdownCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "DropdownCollectionViewCell", for: indexPath as IndexPath) as! DropdownCollectionViewCell
    }
    
    func getTextInputCell(indexPath: IndexPath) -> TextInputCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "TextInputCollectionViewCell", for: indexPath as IndexPath) as! TextInputCollectionViewCell
    }
    
    func getSwitchInputCell(indexPath: IndexPath) -> SwitchInputCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "SwitchInputCollectionViewCell", for: indexPath as IndexPath) as! SwitchInputCollectionViewCell
    }
    
    func getDateInputCell(indexPath: IndexPath) -> DateInputCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "DateInputCollectionViewCell", for: indexPath as IndexPath) as! DateInputCollectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inputItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = inputItems[indexPath.row]
        switch item.type {
        case .Dropdown:
            let cell = getDropdownCell(indexPath: indexPath)
            cell.setup(with: item as! DropdownInput, delegate: inputDelegate!)
            return cell
        case .Text:
            let cell = getTextInputCell(indexPath: indexPath)
            cell.setup(with: item as! TextInput, delegate: inputDelegate!)
            return cell
        case .Int:
            let cell = getTextInputCell(indexPath: indexPath)
            cell.setup(with: item as! TextInput, delegate: inputDelegate!)
            return cell
        case .Double:
            let cell = getTextInputCell(indexPath: indexPath)
            cell.setup(with: item as! TextInput, delegate: inputDelegate!)
            return cell
        case .Date:
            let cell = getDateInputCell(indexPath: indexPath)
            cell.setup(with: item as! DateInput, delegate: inputDelegate!)
            return cell
        case .Switch:
            let cell = getSwitchInputCell(indexPath: indexPath)
            cell.setup(with: item as! SwitchInput, delegate: inputDelegate!)
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
