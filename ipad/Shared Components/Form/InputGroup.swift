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
        "TextAreaInputCollectionViewCell",
        "RadioSwitchInputCollectionViewCell",
        "DoubleInputCollectionViewCell",
        "IntegerInputCollectionViewCell",
        "ViewFieldCollectionViewCell",
        "RadioBooleanCollectionViewCell",
        "TimeInputCollectionViewCell",
        "IntegerStepperInputCollectionViewCell",
        "SpacerCollectionViewCell",
        "InputTitleCollectionViewCell"
    ]
    
    // MARK: Variables
    private weak var collectionView: UICollectionView? = nil
    weak private var inputDelegate: InputDelegate? = nil
    public var inputItems: [InputItem] = []
    private var displayableInputItems: [InputItem] = []
    private var dependencyKeys: [String] = []
    
    public func initialize(with Items: [InputItem], delegate: InputDelegate, in container: UIView) {
        container.addSubview(self)
        self.addConstraints(for: container)
        self.inputItems = Items
        self.setDisplayableItems()
        self.inputDelegate = delegate
        self.createCollectionView()
        self.setupCollectionView()
        addListeners()
        container.layoutIfNeeded()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setDisplayableItems() {
        displayableInputItems = []
        dependencyKeys = []
        for item in inputItems {
            if item.dependency.isEmpty {
                self.displayableInputItems.append(item)
            } else {
                var isSatisfied = true
                for dependency in item.dependency {
                    self.dependencyKeys.append(dependency.item.key)
                    if(!dependency.isSatisfied()) {
                        isSatisfied = false
                    }
                }
                
                if isSatisfied {
                    self.displayableInputItems.append(item)
                }
            }
        }
    }
    
    private func addListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.screenOrientationChanged(notification:)), name: .screenOrientationChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.inputItemValueChanged(notification:)), name: .InputItemValueChanged, object: nil)
    }
    
    @objc func inputItemValueChanged(notification: Notification) {
        guard let item: InputItem = notification.object as? InputItem else {return}
        if dependencyKeys.contains(item.key) {
            self.setDisplayableItems()
            self.collectionView?.performBatchUpdates({
                let indexSet = IndexSet(integersIn: 0...0)
                self.collectionView?.reloadSections(indexSet)
            }, completion: { (done) in
                NotificationCenter.default.post(name: .ShouldResizeInputGroup, object: self)
            })
        }
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
            case .Fill:
                itemWidth = 100 - widthCounter
            }
            // If the new row witdh + current row width exceeds 100, item will be in the next row
            if (widthCounter + itemWidth) > 100 {
                // Store previous row's max height
                rowHeights.append(tempMaxRowItemHeight + assumedCellSpacing)
                tempMaxRowItemHeight = 0
                widthCounter = 0
            }
            
            // TODO: handle height for items with dependency where dependency is not satisfied
            // Its buggy for rows with .Forth width items
            var dependencySatisfied = true
            for dependency in item.dependency where !dependency.isSatisfied() {
                dependencySatisfied = false
                break
            }
            
            if !item.dependency.isEmpty && !dependencySatisfied {
                if index == (items.count - 1) {
                    rowHeights.append(tempMaxRowItemHeight)
                }
                continue
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
    
    func getTimeInputCell(indexPath: IndexPath) ->  TimeInputCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "TimeInputCollectionViewCell", for: indexPath as IndexPath) as! TimeInputCollectionViewCell
    }
    
    func getTextAreaInputCell(indexPath: IndexPath) -> TextAreaInputCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "TextAreaInputCollectionViewCell", for: indexPath as IndexPath) as! TextAreaInputCollectionViewCell
    }
    
    func getRadioSwitchInputCell(indexPath: IndexPath) -> RadioSwitchInputCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "RadioSwitchInputCollectionViewCell", for: indexPath as IndexPath) as! RadioSwitchInputCollectionViewCell
    }
    
    func getDoubleInputCell(indexPath: IndexPath) -> DoubleInputCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "DoubleInputCollectionViewCell", for: indexPath as IndexPath) as! DoubleInputCollectionViewCell
    }
    
    func getIntInputCell(indexPath: IndexPath) -> IntegerInputCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "IntegerInputCollectionViewCell", for: indexPath as IndexPath) as! IntegerInputCollectionViewCell
    }
    
    func getIntStepperInputCell(indexPath: IndexPath) -> IntegerStepperInputCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "IntegerStepperInputCollectionViewCell", for: indexPath as IndexPath) as! IntegerStepperInputCollectionViewCell
    }
    
    func getViewFieldCell(indexPath: IndexPath) -> ViewFieldCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "ViewFieldCollectionViewCell", for: indexPath as IndexPath) as! ViewFieldCollectionViewCell
    }
    
    func getRadioBooleanCell(indexPath: IndexPath) ->  RadioBooleanCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "RadioBooleanCollectionViewCell", for: indexPath as IndexPath) as! RadioBooleanCollectionViewCell
    }
    
    func getSpacerCell(indexPath: IndexPath) ->  SpacerCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "SpacerCollectionViewCell", for: indexPath as IndexPath) as! SpacerCollectionViewCell
    }
    
    func getTitleCell(indexPath: IndexPath) -> InputTitleCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "InputTitleCollectionViewCell", for: indexPath as IndexPath) as! InputTitleCollectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayableInputItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = displayableInputItems[indexPath.row]
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
            let cell = getIntInputCell(indexPath: indexPath)
            cell.setup(with: item as! IntegerInput, delegate: inputDelegate!)
            return cell
        case .Double:
            let cell = getDoubleInputCell(indexPath: indexPath)
            cell.setup(with: item as! DoubleInput, delegate: inputDelegate!)
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
        case .RadioSwitch:
            let cell = getRadioSwitchInputCell(indexPath: indexPath)
            cell.setup(with: item as! RadioSwitchInput, delegate: inputDelegate!)
            return cell
        case .ViewField:
            let cell = getViewFieldCell(indexPath: indexPath)
            cell.setup(with: item as! ViewField, delegate: inputDelegate!)
            return cell
        case .RadioBoolean:
            let cell = getRadioBooleanCell(indexPath: indexPath)
            cell.setup(with: item as! RadioBoolean, delegate: inputDelegate!)
            return cell
        case .Time:
            let cell = getTimeInputCell(indexPath: indexPath)
            cell.setup(with: item as! TimeInput, delegate: inputDelegate!)
            return cell
        case .Stepper:
            let cell = getIntStepperInputCell(indexPath: indexPath)
            cell.setup(with: item as! IntegerStepperInput, delegate: inputDelegate!)
            return cell
        case .Spacer:
            let cell = getSpacerCell(indexPath: indexPath)
            return cell
        case .Title:
            let cell = getTitleCell(indexPath: indexPath)
            cell.setup(with: item as! InputTitle, delegate: inputDelegate!)
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
        
        var previousItemWidth: InputItemWidthSize? = nil
        
        if indexPath.row >= 1 {
            let previous = displayableInputItems[indexPath.row - 1]
            previousItemWidth = previous.width
        }
        
        let item = displayableInputItems[indexPath.row]
        let containerWidth = collectionView.frame.width
        var multiplier: CGFloat = 1
        switch item.width {
        case .Full:
            return CGSize(width: containerWidth, height: item.height)
        case .Half:
            multiplier = 2
        case .Third:
            multiplier = 3
        case .Forth:
            multiplier = 4
        case .Fill:
            if let previousWidth = previousItemWidth {
                switch previousWidth {
                case .Full:
                    return CGSize(width: containerWidth, height: item.height)
                case .Half:
                    multiplier = 2
                case .Third:
                    multiplier = 3
                case .Forth:
                    multiplier = 4
                case .Fill:
                    return CGSize(width: containerWidth, height: item.height)
                }
            } else {
                return CGSize(width: containerWidth, height: item.height)
            }
        }
        
        return CGSize(width: (containerWidth - (multiplier * cellSpacing)) / multiplier, height: item.height)
    }
    
}
