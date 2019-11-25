//
//  ShiftViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-19.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

private enum ShiftOverviewSectionRow: Int, CaseIterable {
    case Header
    case Inspections
}

private enum ShiftInformationSectionRow: Int, CaseIterable {
    case Header
    case StartShift
    case EndShift
}

public enum ShiftViewSection: Int, CaseIterable {
    case Overview = 0
    case Information
}


class ShiftViewController: BaseViewController {
    
    // MARK: Constants
    private let collectionCells = [
        "BasicCollectionViewCell",
        "ShifOverviewHeaderCollectionViewCell",
        "InspectionsTableCollectionViewCell",
        "ShiftInformationHeaderCollectionViewCell"
    ]
    
    // MARK: Varialbes
    var model: ShiftModel?
    var showShiftInfo: Bool = true
    private var isEditable: Bool = true
    
    // MARK: Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createTestModel()
        setupCollectionView()
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
    
    func createTestModel() {
        let model = ShiftModel()
        model.date = Date()
        model.location = "Victoria, BC"
        
        // Create dummy inspections
        let inspection1 = WatercradftInspectionModel()
        inspection1.remoteId = 65100
        inspection1.inspectionTime = 16.00
        inspection1.shouldSync = true
        
        // Create dummy inspections
        let inspection2 = WatercradftInspectionModel()
        inspection2.remoteId = 65102
        inspection2.inspectionTime = 8.00
        inspection2.shouldSync = false
        
        model.inspections.append(inspection1)
        model.inspections.append(inspection2)
        
        self.model = model
    }
}

extension ShiftViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private func setupCollectionView() {
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
    
    func getBasicCell(indexPath: IndexPath) -> BasicCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "BasicCollectionViewCell", for: indexPath as IndexPath) as! BasicCollectionViewCell
    }
    
    func getShiftOverViewCell(indexPath: IndexPath) -> ShifOverviewHeaderCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "ShifOverviewHeaderCollectionViewCell", for: indexPath as IndexPath) as! ShifOverviewHeaderCollectionViewCell
    }
    func getInspectionsTableCell(indexPath: IndexPath) -> InspectionsTableCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "InspectionsTableCollectionViewCell", for: indexPath as IndexPath) as! InspectionsTableCollectionViewCell
    }
    func getShiftInformationHeaderCell(indexPath: IndexPath) -> ShiftInformationHeaderCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "ShiftInformationHeaderCollectionViewCell", for: indexPath as IndexPath) as! ShiftInformationHeaderCollectionViewCell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if model == nil { return 0}
        return ShiftViewSection.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = ShiftViewSection(rawValue: Int(section)) else {return 0}
        switch sectionType {
        case .Overview:
            return ShiftOverviewSectionRow.allCases.count
        case .Information:
            return showShiftInfo ? ShiftInformationSectionRow.allCases.count : 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = ShiftViewSection(rawValue: Int(indexPath.section)) else { return UICollectionViewCell() }
        switch sectionType {
        case .Overview:
            return getShiftOverviewSectionRow(indexPath: indexPath)
        case .Information:
            return getShiftInformationSectionRow(indexPath: indexPath)
        }
    }
    
    
    func getShiftOverviewSectionRow(indexPath: IndexPath) -> UICollectionViewCell {
        guard let rowType = ShiftOverviewSectionRow(rawValue: Int(indexPath.row)), let model = self.model else {return UICollectionViewCell() }
        switch rowType {
        case .Header:
            let cell = getShiftOverViewCell(indexPath: indexPath)
            cell.setup(object: model)
            return cell
        case .Inspections:
            let cell = getInspectionsTableCell(indexPath: indexPath)
            cell.setup(object: model)
            return cell
        }
    }
    
    func getShiftInformationSectionRow(indexPath: IndexPath) -> UICollectionViewCell {
        guard let rowType = ShiftInformationSectionRow(rawValue: Int(indexPath.row)), let model = self.model else {return UICollectionViewCell()}
        switch rowType {
        case .Header:
            let cell = getShiftInformationHeaderCell(indexPath: indexPath)
            cell.setup(isHidden: showShiftInfo) {
                // OnClick
                self.showShiftInfo = !self.showShiftInfo
                self.collectionView.reloadSections(IndexSet(integer: ShiftViewSection.Information.rawValue))
            }
            return cell
        case .StartShift:
            let cell = getBasicCell(indexPath: indexPath)
            let items = model.getShiftStartFields(forModal: false, editable: isEditable)
            cell.setup(title: "Shift Start", input: items, delegate: self, padding: 20)
            return cell
        case .EndShift:
            let cell = getBasicCell(indexPath: indexPath)
            let items = model.getShiftEndFields(editable: isEditable)
            cell.setup(title: "Shift End", input: items, delegate: self, padding: 20)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let sectionType = ShiftViewSection(rawValue: Int(indexPath.section)) else {
            return CGSize(width: 0, height: 0)
        }
        switch sectionType {
        case .Overview:
            return getSizeForShiftOverView(row: ShiftOverviewSectionRow(rawValue: Int(indexPath.row)))
        case .Information:
            return getSizeForShiftInfo(row: ShiftInformationSectionRow(rawValue: Int(indexPath.row)))
        }
        
    }
    
    fileprivate func getSizeForShiftOverView(row: ShiftOverviewSectionRow?) -> CGSize {
        guard let row = row, let model = self.model else {return CGSize(width: 0, height: 0)}
        let fullWdtih = self.collectionView.frame.width
        switch row {
        case .Header:
            return CGSize(width: fullWdtih, height: 62)
        case .Inspections:
            let height = InspectionsTableCollectionViewCell.getTableHeight(for: model)
            return CGSize(width: fullWdtih, height: height)
        }
    }
    
    fileprivate func getSizeForShiftInfo(row: ShiftInformationSectionRow?) -> CGSize {
        guard let row = row else {return CGSize(width: 0, height: 0)}
        let fullWdtih = self.collectionView.frame.width
        switch row {
        case .Header:
            return CGSize(width: fullWdtih, height: 35)
        case .StartShift:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: ShiftFormHelper.getShiftStartFields())
            return CGSize(width: fullWdtih, height: estimatedContentHeight)
        case .EndShift:
             let estimatedContentHeight = InputGroupView.estimateContentHeight(for: ShiftFormHelper.getShiftEndFields())
            return CGSize(width: fullWdtih, height: estimatedContentHeight)
        }
    }
}
