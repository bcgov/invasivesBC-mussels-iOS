//
//  WatercraftInspectionViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-04.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

private enum JourneyDetailsSectionRow {
    case Header
    case PreviousWaterBody
    case DestinationWaterBody
    case AddPreviousWaterBody
    case AddDestinationWaterBody
    case Divider
}

private enum FromSection: Int, CaseIterable {
    case BasicInformation = 0
    case WatercraftDetails
    case JourneyDetails
    case InspectionDetails
    case GeneralComments
}

class WatercraftInspectionViewController: BaseViewController {
    
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Constants
    private let collectionCells = [
        "BasicCollectionViewCell",
        "FormButtonCollectionViewCell",
        "HeaderCollectionViewCell",
        "DividerCollectionViewCell",
        "DestinationWaterBodyCollectionViewCell",
        "PreviousWaterBodyCollectionViewCell"
    ]
    
    // MARK: Variables
    private var isEditable: Bool = true
    private var journeyDetails: JourneyDetailsModel = JourneyDetailsModel()
    private var formResult: [String: Any?] = [String: Any]()
    
    // MARK: Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar(hidden: false, style: UIBarStyle.black)
        setupCollectionView()
        addListeners()
        style()
    }
    
    private func addListeners() {
           NotificationCenter.default.addObserver(self, selector: #selector(self.inputItemValueChanged(notification:)), name: .InputItemValueChanged, object: nil)
    }
    
    @objc func inputItemValueChanged(notification: Notification) {
        guard let item: InputItem = notification.object as? InputItem else {return}
        formResult[item.key] = item.value.get(type: item.type)
        print(formResult)
    }
    
    // Navigation bar right button action
    @objc func action(sender: UIBarButtonItem) {
    }
    
    private func refreshJourneyDetails(index: Int) {
        
    }
    
    private func style() {
        self.styleNavBar()
    }
    
    private func styleNavBar() {
        guard let navigation = self.navigationController else { return }
        self.title = "Watercraft Inspection"
        navigation.navigationBar.isTranslucent = false
        navigation.navigationBar.tintColor = .white
        navigation.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        setGradiantBackground(navigationBar: navigation.navigationBar)
        setRightNavButtonTo(type: .save)
    }
    
    private func setRightNavButtonTo(type: UIBarButtonItem.SystemItem) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: type, target: self, action: #selector(self.action(sender:)))
    }
    
    
}

//UICollectionViewDelegateFlowLayout
extension WatercraftInspectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
    
    func getHeaderCell(indexPath: IndexPath) -> HeaderCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "HeaderCollectionViewCell", for: indexPath as IndexPath) as! HeaderCollectionViewCell
    }
    
    func getButtonCell(indexPath: IndexPath) -> FormButtonCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "FormButtonCollectionViewCell", for: indexPath as IndexPath) as! FormButtonCollectionViewCell
    }
    
    func getDividerCell(indexPath: IndexPath) -> DividerCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "DividerCollectionViewCell", for: indexPath as IndexPath) as! DividerCollectionViewCell
    }
    
    func getPreviousWaterBodyCell(indexPath: IndexPath) -> PreviousWaterBodyCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "PreviousWaterBodyCollectionViewCell", for: indexPath as IndexPath) as! PreviousWaterBodyCollectionViewCell
    }
    
    func getDestinationWaterBodyCell(indexPath: IndexPath) -> DestinationWaterBodyCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "DestinationWaterBodyCollectionViewCell", for: indexPath as IndexPath) as! DestinationWaterBodyCollectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = FromSection(rawValue: Int(section)) else {return 0}
        
        if sectionType == .JourneyDetails {
            return journeyDetails.previousWaterBodies.count + journeyDetails.destinationWaterBodies.count + 4
        } else {
            return 1
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return FromSection.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = FromSection(rawValue: Int(indexPath.section)) else {
            return UICollectionViewCell()
        }
        switch sectionType {
        case .BasicInformation:
            let cell = getBasicCell(indexPath: indexPath)
            cell.setup(title: "Basic Information", input: FormHelper.watercraftInspectionBasciInfoInputs(isEditable: isEditable), delegate: self)
            return cell
        case .WatercraftDetails:
            let cell = getBasicCell(indexPath: indexPath)
            cell.setup(title: "Watercraft Details", input: FormHelper.watercraftInspectionWatercraftDetailsInputs(isEditable: isEditable), delegate: self)
            return cell
        case .JourneyDetails:
            return getJourneyDetailsCell(for: indexPath)
        case .InspectionDetails:
            let cell = getBasicCell(indexPath: indexPath)
            cell.setup(title: "Inspection Details", input: FormHelper.watercraftInspectionInspectionDetailsInputs(isEditable: isEditable), delegate: self)
            return cell
        case .GeneralComments:
            let cell = getBasicCell(indexPath: indexPath)
            cell.setup(title: "Comments", input: FormHelper.watercraftInspectionCommentSectionInputs(isEditable: isEditable), delegate: self)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let sectionType = FromSection(rawValue: Int(indexPath.section)) else {
            return CGSize(width: 0, height: 0)
        }
        switch sectionType {
        case .BasicInformation:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: FormHelper.watercraftInspectionBasciInfoInputs())
            return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight + 80)
        case .WatercraftDetails:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: FormHelper.watercraftInspectionWatercraftDetailsInputs())
            return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight + 80)
        case .JourneyDetails:
            return estimateJourneyDetailsCellHeight(for: indexPath)
        case .InspectionDetails:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: FormHelper.watercraftInspectionInspectionDetailsInputs())
            return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight + 80)
        case .GeneralComments:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: FormHelper.watercraftInspectionCommentSectionInputs())
            return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight + 80)
        }
    }
    
    private func getJourneyDetailsCell(for indexPath: IndexPath) -> UICollectionViewCell {
        switch getJourneyDetailsCellType(for: indexPath) {
            
        case .Header:
            let cell = getHeaderCell(indexPath: indexPath)
            cell.setup(with: "Journey Details")
            return cell
        case .PreviousWaterBody:
            let cell = getPreviousWaterBodyCell(indexPath: indexPath)
            let itemsIndex: Int = indexPath.row - 1
            cell.setup(with: journeyDetails.previousWaterBodies[itemsIndex], delegate: self, onDelete: {
                self.journeyDetails.previousWaterBodies.remove(at: itemsIndex)
                self.collectionView.performBatchUpdates({
                    self.collectionView.deleteItems(at: [indexPath])
                    self.collectionView.reloadSections(IndexSet(integer: indexPath.section))
                }, completion: nil)
                self.collectionView.deleteItems(at: [indexPath])
            })
            return cell
        case .DestinationWaterBody:
            let cell = getDestinationWaterBodyCell(indexPath: indexPath)
            let itemsIndex: Int = indexPath.row - (journeyDetails.previousWaterBodies.count + 2)
            cell.setup(with: journeyDetails.destinationWaterBodies[itemsIndex], delegate: self, onDelete: {
                self.journeyDetails.destinationWaterBodies.remove(at: itemsIndex)
                self.collectionView.performBatchUpdates({
                    self.collectionView.deleteItems(at: [indexPath])
                    self.collectionView.reloadSections(IndexSet(integer: indexPath.section))
                }, completion: nil)
                self.collectionView.deleteItems(at: [indexPath])
            })
            return cell
        case .AddPreviousWaterBody:
            let cell = getButtonCell(indexPath: indexPath)
            cell.setup(with: "Add Prveious Water Body") {
                self.journeyDetails.previousWaterBodies.append(FormHelper.watercraftInspectionPreviousWaterBodyInputs(index: self.journeyDetails.previousWaterBodies.count, isEditable: self.isEditable))
                self.collectionView.performBatchUpdates({
                    self.collectionView.reloadSections(IndexSet(integer: indexPath.section))
                }, completion: nil)
            }
            return cell
        case .AddDestinationWaterBody:
            let cell = getButtonCell(indexPath: indexPath)
            cell.setup(with: "Add Destination Water Body") {
                self.journeyDetails.destinationWaterBodies.append(FormHelper.watercraftInspectionDestinationWaterBodyInputs(index: self.journeyDetails.destinationWaterBodies.count, isEditable: self.isEditable))
                self.collectionView.performBatchUpdates({
                    self.collectionView.reloadSections(IndexSet(integer: indexPath.section))
                }, completion: nil)
            }
            return cell
        case .Divider:
            return getDividerCell(indexPath: indexPath)
        }
    }
    
    private func estimateJourneyDetailsCellHeight(for indexPath: IndexPath) -> CGSize {
        let width = self.collectionView.frame.width
        switch getJourneyDetailsCellType(for: indexPath) {
            
        case .Header:
            return CGSize(width: width, height: 40)
        case .PreviousWaterBody:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: FormHelper.watercraftInspectionPreviousWaterBodyInputs(index: 0))
            return CGSize(width: width, height: estimatedContentHeight + 20)
        case .DestinationWaterBody:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: FormHelper.watercraftInspectionDestinationWaterBodyInputs(index: 0))
            return CGSize(width: width, height: estimatedContentHeight + 20)
        case .AddPreviousWaterBody:
            return CGSize(width: width, height: 50)
        case .AddDestinationWaterBody:
            return CGSize(width: width, height: 50)
        case .Divider:
            return CGSize(width: width, height: 10)
        }
    }
    
    private func getJourneyDetailsCellType(for indexPath: IndexPath) -> JourneyDetailsSectionRow {
        if indexPath.row == 0 {
            return .Header
        }
        
        if indexPath.row == journeyDetails.previousWaterBodies.count + 1 {
            return .AddPreviousWaterBody
        }
        
        if indexPath.row == journeyDetails.previousWaterBodies.count + journeyDetails.destinationWaterBodies.count + 2 {
            return .AddDestinationWaterBody
        }
        
        if indexPath.row <= journeyDetails.previousWaterBodies.count {
            return .PreviousWaterBody
        }
        
        if indexPath.row <= (journeyDetails.previousWaterBodies.count + journeyDetails.destinationWaterBodies.count + 1) {
            return .DestinationWaterBody
        }
        
        return .Divider
    }
}
