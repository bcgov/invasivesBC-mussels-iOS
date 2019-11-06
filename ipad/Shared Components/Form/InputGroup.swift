//
//  InputGroup.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-03.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class InputGroupView: UIView {
    
    // MARK: Constants
    private let collectionCells = [
        "TextInputCollectionViewCell",
        "DropdownCollectionViewCell",
        "SwitchInputCollectionViewCell",
        "DateInputCollectionViewCell",
        "TextAreaInputCollectionViewCell"
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
    
    public func initialize(with Items: [InputItem], delegate: InputDelegate, in container: UIView) {
        container.addSubview(self)
        self.addConstraints(for: container)
        self.inputItems = Items
        self.inputDelegate = delegate
        self.createCollectionView()
        self.setupCollectionView()
        addFildChangeListener()
        container.layoutIfNeeded()
    }
    
    private func addFildChangeListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.inputItemValueChanged(notification:)), name: .InputItemValueChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.screenOrientationChanged(notification:)), name: .screenOrientationChanged, object: nil)
    }
    
    @objc func inputItemValueChanged(notification: Notification) {
        guard let item: InputItem = notification.object as? InputItem else {
            return
        }
//        print("\(item.value.get(type: item.type) ?? "")")
    }
    
    @objc func screenOrientationChanged(notification: Notification) {
        guard let collectionView = collectionView, let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.invalidateLayout()
        
    }
    
    private func addConstraints(for view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        self.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        self.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func createCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.frame.height, height: self.frame.height), collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .clear
        collection.isScrollEnabled = false
        self.collectionView = collection
        self.addSubview(collection)
        addCollectionVIewConstraints()
    }
    
    private func addCollectionVIewConstraints() {
        guard let collection = self.collectionView else {return}
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        collection.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        collection.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        collection.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    // Calculates the estimated height needed to display an array of input items
    public static func estimateContentHeight(for items: [InputItem]) -> CGFloat {
        let assumedCellSpacing: CGFloat = 10
        var rowHeights: [CGFloat] = []
        var widthCounter: CGFloat = 0
        var tempMaxRowItemHeight: CGFloat = 0
        for (index, item) in items.enumerated()  {
            var itemWidth: CGFloat = 0
            // Get Width in terms of screen %
            switch item.width {
            case .Full:
                itemWidth = 100
            case .Half:
                itemWidth = 50
            case .Third:
                itemWidth = 33
            case .Forth:
                itemWidth = 25
            }
            // If the new row witdh + current row width exceeds 100, item will be in the next row
            if (widthCounter + itemWidth) > 100 {
                // Store previous row's max height
                rowHeights.append(tempMaxRowItemHeight + assumedCellSpacing)
                tempMaxRowItemHeight = 0
                widthCounter = 0
            }
            
            // If current item's height is greater than the max item height for row
            // set max item hight for row
            if tempMaxRowItemHeight < item.height {
                tempMaxRowItemHeight = item.height
            }
            // increase width counter
            widthCounter = widthCounter + itemWidth
            
            // if its the last item, add rowheight
            if index == (items.count - 1) {
                rowHeights.append(tempMaxRowItemHeight)
            }
        }
        
        var computedHeight: CGFloat = 0
        for rowHeight in rowHeights {
            computedHeight = computedHeight + rowHeight
        }
        print("\(rowHeights.count) rows -> \(computedHeight)")
        return computedHeight
    }
}

extension InputGroupView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
    
    func getTextAreaInputCell(indexPath: IndexPath) -> TextAreaInputCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "TextAreaInputCollectionViewCell", for: indexPath as IndexPath) as! TextAreaInputCollectionViewCell
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
        case .TextArea:
            let cell = getTextAreaInputCell(indexPath: indexPath)
            cell.setup(with: item as! TextAreaInput, delegate: inputDelegate!)
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
