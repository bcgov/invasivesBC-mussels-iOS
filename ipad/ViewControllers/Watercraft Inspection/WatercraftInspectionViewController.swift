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

public enum WatercraftFromSection: Int, CaseIterable {
    case PassportInfo = 0
    case BasicInformation
    case WatercraftDetails
    case JourneyDetails
    case InspectionDetails
    case HighRiskAssessmentFields
    case Divider
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
        "PreviousWaterBodyCollectionViewCell",
    ]
    
    // MARK: Variables
    var shiftModel: ShiftModel?
    var model: WatercradftInspectionModel? = nil
    private var showFullInspection: Bool = false
    private var isEditable: Bool = true
    private var journeyDetails: JourneyDetailsModel = JourneyDetailsModel()
    private var formResult: [String: Any?] = [String: Any]()
    
    // MARK: Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        style()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addListeners()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.collectionView.reloadData()
    }
    
    func initialize(model: WatercradftInspectionModel, editable: Bool) {
        self.model = model
        self.isEditable = editable
        if !model.isPassportHolder || model.launchedOutsideBC {
            self.showFullInspection = true
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? HighRiskFormViewController, let model = self.model, let assessment = model.addHighRiskAssessment() {
            destination.initialize(with: assessment, isEditable: isEditable)
        }
    }
    
    func showHighRiskForm() {
        self.performSegue(withIdentifier: "showHighRiskForm", sender: self)
    }
    
    private func addListeners() {
        NotificationCenter.default.removeObserver(self, name: .InputItemValueChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: .ShouldResizeInputGroup, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.inputItemValueChanged(notification:)), name: .InputItemValueChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.shouldResizeInputGroup(notification:)), name: .ShouldResizeInputGroup, object: nil)
    }
    
    private func refreshJourneyDetails(index: Int) {
        
    }
    
    // MARK: Style
    private func style() {
        setNavigationBar(hidden: false, style: UIBarStyle.black)
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
    
    // MARK: Navigation
    // Navigation bar right button action
    @objc func action(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Notification functions
    @objc func shouldResizeInputGroup(notification: Notification) {
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: Input Item Changed
    @objc func inputItemValueChanged(notification: Notification) {
        guard var item: InputItem = notification.object as? InputItem else {return}
        formResult[item.key] = item.value.get(type: item.type)
        // Set value in Realm object
        if let m = model {
            // Keys that need a pop up/ additional actions
            if (item.key == "highriskAIS" || item.key == "adultDreissenidFound" ) {
                let value = item.value.get(type: item.type) as? Bool
                if value == true {
                    let highRiskModal: HighRiskModalView = HighRiskModalView.fromNib()
                    highRiskModal.initialize(onSubmit: {
                        // Confirmed
                        m.set(value: true, for: item.key)
                        // Show high risk form
                        self.showHighRiskForm()
                    }) {
                        // Cancelled
                        m.set(value: false, for: item.key)
                        item.value.set(value: false, type: item.type)
                        NotificationCenter.default.post(name: .InputFieldShouldUpdate, object: item)
                    }
                }
            } else {
                // All other keys, store directly
                // TODO: needs cleanup for nil case
                m.set(value: item.value.get(type: item.type) as Any, for: item.key)
            }
            
        }
        // Handle Keys that alter form
        if item.key == "isPassportHolder" {
            // If is NOT passport holder, Show full form
            let fieldValue = item.value.get(type: item.type) as? Bool ?? nil
            if fieldValue == false {
                self.showFullInspection = true
            } else {
                self.showFullInspection = false
            }
            self.collectionView.reloadData()
        }
        if item.key == "launchedOutsideBC" {
            // If IS passport holder, && launched outside BC, Show full form
            let fieldValue = item.value.get(type: item.type) as? Bool ?? nil
            let isPassportHolder = formResult["isPassportHolder"] as? Bool ?? nil
            if (fieldValue == true && isPassportHolder == true) {
                self.showFullInspection = true
            } else {
                self.showFullInspection = false
            }
            
            self.collectionView.reloadData()
        }
    }
    
}

// MARK: CollectionView
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
        guard let sectionType = WatercraftFromSection(rawValue: Int(section)) else {return 0}
        
        if sectionType == .JourneyDetails {
            return journeyDetails.previousWaterBodies.count + journeyDetails.destinationWaterBodies.count + 4
        } else {
            return 1
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if showFullInspection {
            return WatercraftFromSection.allCases.count
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = WatercraftFromSection(rawValue: Int(indexPath.section)), let model = self.model else {
            return UICollectionViewCell()
        }
        switch sectionType {
        case .PassportInfo:
            let cell = getBasicCell(indexPath: indexPath)
            cell.setup(title: "Passport Information", input: model.getInputputFields(for: sectionType, editable: isEditable), delegate: self)
            return cell
        case .BasicInformation:
            let cell = getBasicCell(indexPath: indexPath)
            cell.setup(title: "Basic Information", input: model.getInputputFields(for: sectionType, editable: isEditable), delegate: self)
            return cell
        case .WatercraftDetails:
            let cell = getBasicCell(indexPath: indexPath)
            cell.setup(title: "Watercraft Details", input: model.getInputputFields(for: sectionType, editable: isEditable), delegate: self)
            return cell
        case .JourneyDetails:
            return getJourneyDetailsCell(for: indexPath)
        case .InspectionDetails:
            let cell = getBasicCell(indexPath: indexPath)
            cell.setup(title: "Inspection Details", input: model.getInputputFields(for: sectionType, editable: isEditable), delegate: self, showDivider: false)
            return cell
        case .HighRiskAssessmentFields:
            let cell = getBasicCell(indexPath: indexPath)
            cell.setup(title: "High Risk Assessment Fields", input: model.getInputputFields(for: sectionType, editable: isEditable), delegate: self, boxed: true, showDivider: false)
            return cell
        case .GeneralComments:
            let cell = getBasicCell(indexPath: indexPath)
            cell.setup(title: "Comments", input: model.getInputputFields(for: sectionType, editable: isEditable), delegate: self)
            return cell
        case .Divider:
            return getDividerCell(indexPath: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let sectionType = WatercraftFromSection(rawValue: Int(indexPath.section)), let model = self.model else {
            return CGSize(width: 0, height: 0)
        }
        switch sectionType {
        case .PassportInfo:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: model.getInputputFields(for: sectionType))
            return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight + 80)
        case .BasicInformation:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: model.getInputputFields(for: sectionType))
            return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight + 80)
        case .WatercraftDetails:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: model.getInputputFields(for: sectionType))
            return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight + 80)
        case .JourneyDetails:
            return estimateJourneyDetailsCellHeight(for: indexPath)
        case .InspectionDetails:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: model.getInputputFields(for: sectionType))
            return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight + 80)
        case .HighRiskAssessmentFields:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: model.getInputputFields(for: sectionType))
            return CGSize(width: self.collectionView.bounds.width - 16, height: estimatedContentHeight + 80)
        case .GeneralComments:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: model.getInputputFields(for: sectionType))
            return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight + 80)
        case .Divider:
            return CGSize(width: self.collectionView.frame.width, height: 30)
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
                    self.collectionView.reloadSections(IndexSet(integer: indexPath.section))
                }, completion: nil)
            })
            return cell
        case .DestinationWaterBody:
            let cell = getDestinationWaterBodyCell(indexPath: indexPath)
            let itemsIndex: Int = indexPath.row - (journeyDetails.previousWaterBodies.count + 2)
            cell.setup(with: journeyDetails.destinationWaterBodies[itemsIndex], delegate: self, onDelete: {
                self.journeyDetails.destinationWaterBodies.remove(at: itemsIndex)
                self.collectionView.performBatchUpdates({
                    self.collectionView.reloadSections(IndexSet(integer: indexPath.section))
                }, completion: nil)
            })
            return cell
        case .AddPreviousWaterBody:
            let cell = getButtonCell(indexPath: indexPath)
            cell.setup(with: "Add Prveious Water Body") {
                self.journeyDetails.previousWaterBodies.append(WatercraftInspectionFormHelper.watercraftInspectionPreviousWaterBodyInputs(index: self.journeyDetails.previousWaterBodies.count, isEditable: self.isEditable))
                self.collectionView.performBatchUpdates({
                    self.collectionView.reloadSections(IndexSet(integer: indexPath.section))
                }, completion: nil)
            }
            return cell
        case .AddDestinationWaterBody:
            let cell = getButtonCell(indexPath: indexPath)
            cell.setup(with: "Add Destination Water Body") {
                self.journeyDetails.destinationWaterBodies.append(WatercraftInspectionFormHelper.watercraftInspectionDestinationWaterBodyInputs(index: self.journeyDetails.destinationWaterBodies.count, isEditable: self.isEditable))
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
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: WatercraftInspectionFormHelper.watercraftInspectionPreviousWaterBodyInputs(index: 0))
            return CGSize(width: width, height: estimatedContentHeight + 20)
        case .DestinationWaterBody:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: WatercraftInspectionFormHelper.watercraftInspectionDestinationWaterBodyInputs(index: 0))
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
