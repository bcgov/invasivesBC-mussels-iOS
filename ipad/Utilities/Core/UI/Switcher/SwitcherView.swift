//
//  Switcher.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-31.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class SwitcherView: UIView, Theme {
    
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Constants
    let switcherCellName = "SwitcherCollectionViewCell"
    
    // MARK: Variables
    var items: [String] = []
    var activeIndex: Int = -1
    var callBack: ((_ selection: String)-> Void)?
    
    // MARK: Setup
    func setup(with items: [String], selected: String?, callBack: @escaping(_ value: String)->Void) {
        self.items = items
        self.callBack = callBack
        if let selectedItem = selected {
            self.activeIndex = self.items.firstIndex(of: selectedItem) ?? -1
        }
        setupCollectionView()
    }
    
    private func selectedItem(at index: Int) {
        guard let callback = self.callBack else {return}
        let prevIndex = activeIndex
        activeIndex = index
        callback(items[index])
        self.collectionView.reloadItems(at: [IndexPath(row: prevIndex, section: 0), IndexPath(row: index, section: 0)])
    }
    
}

extension SwitcherView: UICollectionViewDataSource, UICollectionViewDelegate {
    private func setupCollectionView() {
        register(cell: switcherCellName)
        collectionView.collectionViewLayout = getLayout()
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func getLayout() -> UICollectionViewFlowLayout{
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = getMaxItemSize()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        return layout
    }
    
    func register(cell name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: name)
    }
    
    func getSwitcherCell(indexPath: IndexPath) -> SwitcherCollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: switcherCellName, for: indexPath as IndexPath) as! SwitcherCollectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = getSwitcherCell(indexPath: indexPath)
        cell.setup(title: items[indexPath.row], isActive: indexPath.row == activeIndex) {
            self.selectedItem(at: indexPath.row)
        }
        return cell
    }
    
    /*
     Unused.
     To set cell size based on content of item,
     - Add UICollectionViewDelegateFlowLayout
     and this function will be used
    */
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeFor(item: items[indexPath.row])
    }
    
    private func sizeFor(item: String) -> CGSize {
        let horizontalPadding: CGFloat = 30
        let sizeForContent =  item.size(withAttributes: [
            NSAttributedString.Key.font : getSwitcherFont()
        ])
        return CGSize(width: sizeForContent.width + horizontalPadding, height: self.frame.size.height)
    }
    
    private func getMaxItemSize() -> CGSize {
        var longestItem = ""
        for item in items where item.count > longestItem.count {
            longestItem = item
        }
        return sizeFor(item: longestItem)
    }
}
