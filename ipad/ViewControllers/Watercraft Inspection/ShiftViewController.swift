//
//  ShiftViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-19.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class ShiftViewController: BaseViewController {
    // MARK: Outlets
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var addInspectionButton: UIButton!
    @IBOutlet weak var titleLabel: NSLayoutConstraint!
    @IBOutlet weak var shiftNumberLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var tempContainer: UIView!
    // MARK: Constants
    private let collectionCells = [
        "BasicCollectionViewCell",
    ]
    
    // MARK: Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupTestTable()
    }
    
    // TEMP
    func setupTestTable() {
        let table = Table()
        table.showTest(container: tempContainer)
    }
    
    // MARK: Style
    private func style() {
        setNavigationBar(hidden: false, style: UIBarStyle.black)
        self.styleNavBar()
        styleCard(layer: containerView.layer)
    }
    
    private func styleNavBar() {
        guard let navigation = self.navigationController else { return }
        self.title = "Shift Overview"
        navigation.navigationBar.isTranslucent = false
        navigation.navigationBar.tintColor = .white
        navigation.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        setGradiantBackground(navigationBar: navigation.navigationBar)
    }
}

//extension ShiftViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
//    private func setupCollectionView() {
//        for cell in collectionCells {
//            register(cell: cell)
//        }
//        collectionView.delegate = self
//        collectionView.dataSource = self
//    }
//    
//    func register(cell name: String) {
//        guard let collectionView = self.collectionView else {return}
//        let nib = UINib(nibName: name, bundle: nil)
//        collectionView.register(nib, forCellWithReuseIdentifier: name)
//    }
//    
//    func getBasicCell(indexPath: IndexPath) -> BasicCollectionViewCell {
//        return collectionView!.dequeueReusableCell(withReuseIdentifier: "BasicCollectionViewCell", for: indexPath as IndexPath) as! BasicCollectionViewCell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        <#code#>
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        <#code#>
//    }
//}
