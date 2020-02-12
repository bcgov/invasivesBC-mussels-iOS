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
    case HighRiskAssessment
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
    private var showHighRiskAssessment: Bool = false
    private var showFullHighRiskAssessment = false
    private var isEditable: Bool = true
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func setup(model: WatercradftInspectionModel) {
        self.model = model
        self.isEditable = model.getStatus() == .Draft
        self.styleNavBar()
        if !model.isPassportHolder || model.launchedOutsideBC {
            self.showFullInspection = true
        }
        
        self.showHighRiskAssessment = shouldShowHighRiskForm()
        self.showFullHighRiskAssessment = shouldShowFullHighRiskForm()
    }
    
    func shouldShowHighRiskForm() -> Bool {
        guard let model = self.model else {return false}
        let highRiskFieldKeys = WatercraftInspectionFormHelper.getHighriskAssessmentFieldsFields().map{ $0.key}
        for key in highRiskFieldKeys {
            if model[key] as? Bool == true {
                return true
            }
        }
        return false
    }
    
    func shouldShowFullHighRiskForm() -> Bool {
        guard let model = self.model, let highRisk = model.highRiskAssessments.first else {return false}
        return !highRisk.cleanDrainDryAfterInspection
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? HighRiskFormViewController, let model = self.model, let assessment = model.addHighRiskAssessment() {
            destination.setup(with: assessment, editable: self.isEditable)
        }
    }
    
    func showHighRiskForm(show: Bool) {
        self.showHighRiskAssessment = show
        self.collectionView.reloadData()
    }
    
    func showFullHighRiskForm(show: Bool) {
        showFullHighRiskAssessment = show
        self.collectionView.reloadData()
    }
    
    private func addListeners() {
        NotificationCenter.default.removeObserver(self, name: .InputItemValueChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: .ShouldResizeInputGroup, object: nil)
        NotificationCenter.default.removeObserver(self, name: .journeyItemValueChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.inputItemValueChanged(notification:)), name: .InputItemValueChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.shouldResizeInputGroup(notification:)), name: .ShouldResizeInputGroup, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.journeyItemValueChanged(notification:)), name: .journeyItemValueChanged, object: nil)
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
        if let model = self.model, model.getStatus() == .Draft {
            setRightNavButtonTo(type: .save)
        }
    }
    
    private func setRightNavButtonTo(type: UIBarButtonItem.SystemItem) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: type, target: self, action: #selector(self.action(sender:)))
    }
    
    // MARK: Navigation
    // Navigation bar right button action
    @objc func action(sender: UIBarButtonItem) {
        self.dismissKeyboard()
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Notification functions
    @objc func shouldResizeInputGroup(notification: Notification) {
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: Input Item Changed
    @objc func inputItemValueChanged(notification: Notification) {
        guard var item: InputItem = notification.object as? InputItem, let model = self.model else {return}
        // Set value in Realm object
        // Keys that need a pop up/ additional actions
        let highRiskFieldKeys = WatercraftInspectionFormHelper.getHighriskAssessmentFieldsFields().map{ $0.key}
        if highRiskFieldKeys.contains(item.key) {
            let value = item.value.get(type: item.type) as? Bool
            if value == true {
                let highRiskModal: HighRiskModalView = HighRiskModalView.fromNib()
                highRiskModal.initialize(onSubmit: {
                    // Confirmed
                    model.set(value: true, for: item.key)
                    // Show high risk form
                    self.showHighRiskForm(show: true)
                }) {
                    // Cancelled
                    model.set(value: false, for: item.key)
                    item.value.set(value: false, type: item.type)
                    NotificationCenter.default.post(name: .InputFieldShouldUpdate, object: item)
                }
            } else {
                model.set(value: false, for: item.key)
                self.showHighRiskForm(show: shouldShowHighRiskForm())
            }
        } else if
            item.key.lowercased().contains("previousWaterBody".lowercased()) ||
                item.key.lowercased().contains("destinationWaterBody".lowercased())
        {
            // Watercraft Journey
            model.editJourney(inputItemKey: item.key, value: item.value.get(type: item.type) as Any)
        } else if item.key.lowercased().contains("highRisk-".lowercased()) {
            // High Risk Assessment
            model.editHighRiskForm(inputItemKey: item.key, value: item.value.get(type: item.type) as Any)
            if item.key == "highRisk-cleanDrainDryAfterInspection" {
                guard let value = item.value.get(type: .RadioBoolean) as? Bool else {return}
                self.showFullHighRiskForm(show: !value)
            }
        } else {
            // All other keys, store directly
            // TODO: needs cleanup for nil case
            model.set(value: item.value.get(type: item.type) as Any, for: item.key)
        }
        // TODO: CLEANUP
        // Handle Keys that alter form
        if item.key.lowercased() == "isPassportHolder".lowercased() {
            // If is NOT passport holder, Show full form
            let fieldValue = item.value.get(type: item.type) as? Bool ?? nil
            if fieldValue == false {
                self.showFullInspection = true
            } else {
                if model.launchedOutsideBC {
                    self.showFullInspection = true
                } else {
                    self.showFullInspection = false
                }
            }
            self.collectionView.reloadData()
        }
        if item.key.lowercased() == "launchedOutsideBC".lowercased() {
            // If IS passport holder, && launched outside BC, Show full form
            let launchedOutsideBC = item.value.get(type: item.type) as? Bool ?? nil
            if (launchedOutsideBC == true && model.isPassportHolder == true) {
                self.showFullInspection = true
            } else {
                self.showFullInspection = false
            }
            
            self.collectionView.reloadData()
        }
    }
    
    @objc func journeyItemValueChanged(notification: Notification) {
        guard let item: InputItem = notification.object as? InputItem, let model = self.model else {return}
        model.editJourney(inputItemKey: item.key, value: item.value.get(type: item.type) as Any)
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
        guard let sectionType = WatercraftFromSection(rawValue: Int(section)), let model = self.model else {return 0}
        
        switch sectionType {
        case .JourneyDetails:
            return model.previousWaterBodies.count + model.destinationWaterBodies.count + 4
        case .HighRiskAssessment:
            if !showHighRiskAssessment {
                return 0
            }
            if self.showFullHighRiskAssessment == true {
                return HighRiskFormSection.allCases.count
            } else {
                return 2
            }
        default:
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
        case .HighRiskAssessment:
            return getHighRiskAssessmentCell(indexPath: indexPath)
        case .GeneralComments:
            let cell = getBasicCell(indexPath: indexPath)
            cell.setup(title: "Comments", input: model.getInputputFields(for: sectionType, editable: isEditable), delegate: self)
            return cell
        case .Divider:
            return getDividerCell(indexPath: indexPath)
        }
    }
    
    func getHighRiskAssessmentCell(indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = HighRiskFormSection(rawValue: Int(indexPath.row)), let model = self.model, let highRiskForm = model.highRiskAssessments.first else {
            return UICollectionViewCell()
        }
        
        let sectionTitle = "\(sectionType)".convertFromCamelCase()
        let cell = getBasicCell(indexPath: indexPath)
        cell.setup(title: sectionTitle, input: highRiskForm.getInputputFields(for: sectionType, editable: isEditable), delegate: self)
        return cell
    }
    
    func getSizeForHighRiskAssessmentCell(indexPath: IndexPath) -> CGSize {
        guard let sectionType = HighRiskFormSection(rawValue: Int(indexPath.row)), let model = self.model, let highRiskForm = model.highRiskAssessments.first else {
            return CGSize()
        }
        
        let estimatedContentHeight = InputGroupView.estimateContentHeight(for: highRiskForm.getInputputFields(for: sectionType))
        return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight + 80)
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
        case .HighRiskAssessment:
            return getSizeForHighRiskAssessmentCell(indexPath: indexPath)
        case .GeneralComments:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: model.getInputputFields(for: sectionType))
            return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight + 80)
        case .Divider:
            return CGSize(width: self.collectionView.frame.width, height: 30)
        }
    }
    
    private func getJourneyDetailsCell(for indexPath: IndexPath) -> UICollectionViewCell {
        guard let model = self.model else {return UICollectionViewCell()}
        switch getJourneyDetailsCellType(for: indexPath) {
        case .Header:
            let cell = getHeaderCell(indexPath: indexPath)
            cell.setup(with: "Journey Details")
            return cell
        case .PreviousWaterBody:
            let cell = getPreviousWaterBodyCell(indexPath: indexPath)
            let itemsIndex: Int = indexPath.row - 1
            let previousWaterBody = model.previousWaterBodies[itemsIndex]
//            let inputItems = WatercraftInspectionFormHelper.watercraftInspectionPreviousWaterBodyInputs(for: model, index: itemsIndex, isEditable: self.isEditable)
            cell.setup(with: previousWaterBody, isEditable: self.isEditable, delegate: self, onDelete: {
                model.removePreviousWaterBody(at: itemsIndex)
                self.collectionView.performBatchUpdates({
                    self.collectionView.reloadSections(IndexSet(integer: indexPath.section))
                }, completion: nil)
            })
            return cell
        case .DestinationWaterBody:
            let cell = getDestinationWaterBodyCell(indexPath: indexPath)
            let itemsIndex: Int = indexPath.row - (model.previousWaterBodies.count + 2)
            let destinationWaterBody = model.destinationWaterBodies[itemsIndex]
//            let inputItems = WatercraftInspectionFormHelper.watercraftInspectionDestinationWaterBodyInputs(for: model, index: itemsIndex, isEditable: self.isEditable)
            cell.setup(with: destinationWaterBody, isEditable: self.isEditable, delegate: self, onDelete: {
                model.removeDestinationWaterBody(at: itemsIndex)
                self.collectionView.performBatchUpdates({
                    self.collectionView.reloadSections(IndexSet(integer: indexPath.section))
                }, completion: nil)
            })
            return cell
        case .AddPreviousWaterBody:
            let cell = getButtonCell(indexPath: indexPath)
            cell.setup(with: "Add Previous Water Body", isEnabled: isEditable) {
                /// ---------waterbody picker------------
                self.setNavigationBar(hidden: true, style: .black)
                let waterBodyPicker: WaterbodyPicker = UIView.fromNib()
                self.viewLayoutMarginsDidChange()
                waterBodyPicker.setup() { (result) in
                    print(result)
                    for waterBody in result {
                        model.addPreviousWaterBody(model: waterBody)
                    }
                    self.setNavigationBar(hidden: false, style: .black)
                    self.viewLayoutMarginsDidChange()
                    self.collectionView.reloadData()
                    //                    self.collectionView.performBatchUpdates({
                    //                        self.collectionView.reloadSections(IndexSet(integer: indexPath.section))
                    //                    }, completion: nil)
                }
                /// --------------------------------
                
            }
            return cell
        case .AddDestinationWaterBody:
            let cell = getButtonCell(indexPath: indexPath)
            cell.setup(with: "Add Destination Water Body", isEnabled: isEditable) {
                /// ---------waterbody picker------------
                self.setNavigationBar(hidden: true, style: .black)
                let waterBodyPicker: WaterbodyPicker = UIView.fromNib()
                self.viewLayoutMarginsDidChange()
                waterBodyPicker.setup() { (result) in
                    print(result)
                    for waterBody in result {
                        model.addDestinationWaterBody(model: waterBody)
                    }
                    self.setNavigationBar(hidden: false, style: .black)
                    self.viewLayoutMarginsDidChange()
                    self.collectionView.reloadData()
                    //                    self.collectionView.performBatchUpdates({
                    //                        self.collectionView.reloadSections(IndexSet(integer: indexPath.section))
                    //                    }, completion: nil)
                }
                /// --------------------------------
                
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
        guard let model = self.model else {return .Divider}
        if indexPath.row == 0 {
            return .Header
        }
        
        if indexPath.row == model.previousWaterBodies.count + 1 {
            return .AddPreviousWaterBody
        }
        
        if indexPath.row == model.previousWaterBodies.count + model.destinationWaterBodies.count + 2 {
            return .AddDestinationWaterBody
        }
        
        if indexPath.row <= model.previousWaterBodies.count {
            return .PreviousWaterBody
        }
        
        if indexPath.row <= (model.previousWaterBodies.count + model.destinationWaterBodies.count + 1) {
            return .DestinationWaterBody
        }
        
        return .Divider
    }
}
