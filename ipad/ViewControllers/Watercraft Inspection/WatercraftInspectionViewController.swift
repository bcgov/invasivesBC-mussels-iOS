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
    
    // MARK: Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar(hidden: false, style: UIBarStyle.black)
        setupCollectionView()
        style()
    }
    
    private func getDummyOptions() -> [DropdownModel]{
        var options: [DropdownModel] = []
        options.append(DropdownModel(display: "Something here"))
        options.append(DropdownModel(display: "Something else here"))
        options.append(DropdownModel(display: "Something more here"))
        options.append(DropdownModel(display: "Another thing"))
        return options
    }
    
    private func getBasciInfoInputs() -> [InputItem] {
        var sectionItems: [InputItem] = []
        let dateOfInspection = DateInput(key: "dateOfInspection", header: "Date of inspection", editable: isEditable, width: .Forth)
        let provinceOfBoatResidence = DropdownInput(key: "provinceOfBoatResidence", header: "State / Province of boat residence", editable: isEditable, width: .Forth, dropdownItems: getDummyOptions())
        let numberOfWatercrafts = DropdownInput(key: "numberOfWatercrafts", header: "Number of Watercrafts", editable: isEditable, width: .Forth, dropdownItems: getDummyOptions())
        let multipleTypesOfCraft =  SwitchInput(key: "multipleTypesOfCraft", header: "Multiple types of watercraft?", editable: isEditable, width: .Forth)
        sectionItems.append(dateOfInspection)
        sectionItems.append(provinceOfBoatResidence)
        sectionItems.append(numberOfWatercrafts)
        sectionItems.append(multipleTypesOfCraft)
        return sectionItems
    }
    
    private func getWatercraftDetailsInputs() -> [InputItem] {
        var sectionItems: [InputItem] = []
        let numberOfPeople = TextInput(key: "numberOfPeople", header: "Number of people in the party?", editable: isEditable, width: .Third)
        
        let commerciallyHauled =  SwitchInput(key: "commerciallyHauled", header: "Was the watercraft/equipment commercially hauled?", editable: isEditable, width: .Third)
        let highRiskArea =  SwitchInput(key: "highRiskArea", header: "Is the watercraft coming froma high risk area for whirling disease?", editable: isEditable, width: .Third)
        let previousInspection =  SwitchInput(key: "previousInspection", header: "Any previous inspection and/ or agency notification?", editable: isEditable, width: .Third)
        let previousAISknowledge =  SwitchInput(key: "previousAISknowledge", header: "Previous knowledge of AIS or Clean, Drai, Dry?", editable: isEditable, width: .Third)
        
        sectionItems.append(numberOfPeople)
        sectionItems.append(commerciallyHauled)
        sectionItems.append(highRiskArea)
        sectionItems.append(previousInspection)
        sectionItems.append(previousAISknowledge)
        return sectionItems
    }
    
    private func getInspectionDetailsInputs() -> [InputItem] {
        var sectionItems: [InputItem] = []
        
        let aquaticPlantsFound =  SwitchInput(key: "aquaticPlantsFound", header: "Any Aquatic plants found?", editable: isEditable, width: .Third)
        let marineMusslesFound =  SwitchInput(key: "marineMusslesFound", header: "Any marine mussels or barnacles found?", editable: isEditable, width: .Third)
        let failedToStop =  SwitchInput(key: "failedToStop", header: "Was the watercraft pulled over for failing to stop at the inspection station?", editable: isEditable, width: .Third)
        let adultDreissenidFound =  SwitchInput(key: "adultDreissenidFound", header: "Were adult dreissenid mussels found?", editable: isEditable, width: .Third)
        let highRiskForDreissenid =  SwitchInput(key: "highRiskForDreissenid", header: "Is the wartercraft/equipment high risk for dreissenid or other AIS? *", editable: isEditable, width: .Third)
        let passportIssued =  SwitchInput(key: "passportIssued", header: "Was a Passport issued?", editable: isEditable, width: .Third)
        
        sectionItems.append(aquaticPlantsFound)
        sectionItems.append(marineMusslesFound)
        sectionItems.append(failedToStop)
        sectionItems.append(adultDreissenidFound)
        sectionItems.append(highRiskForDreissenid)
        sectionItems.append(passportIssued)
        return sectionItems
    }
    
    private func getCommentSectionInputs() -> [InputItem] {
        var sectionItems: [InputItem] = []
        let generalComments = TextAreaInput(key: "generalComments", header: "General Comments", editable: isEditable)
        sectionItems.append(generalComments)
        return sectionItems
    }
    
    
    // Navigation bar right button action
    @objc func action(sender: UIBarButtonItem) {
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
        guard let sectionType = FromSection(rawValue: Int(section)) else {
            return 0
        }
        
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
            cell.setup(title: "Basic Information", input: getBasciInfoInputs(), delegate: self)
            return cell
        case .WatercraftDetails:
            let cell = getBasicCell(indexPath: indexPath)
            cell.setup(title: "Watercraft Details", input: getWatercraftDetailsInputs(), delegate: self)
            return cell
        case .JourneyDetails:
            return getJourneyDetailsCell(for: indexPath)
        case .InspectionDetails:
            let cell = getBasicCell(indexPath: indexPath)
            cell.setup(title: "Inspection Details", input: getInspectionDetailsInputs(), delegate: self)
            return cell
        case .GeneralComments:
            let cell = getBasicCell(indexPath: indexPath)
            cell.setup(title: "Comments", input: getCommentSectionInputs(), delegate: self)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let sectionType = FromSection(rawValue: Int(indexPath.section)) else {
            return CGSize(width: 0, height: 0)
        }
        switch sectionType {
        case .BasicInformation:
            let estimatedContentHeight = estimateBasicCellContentHeight(for: getBasciInfoInputs())
            return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight)
        case .WatercraftDetails:
            let estimatedContentHeight = estimateBasicCellContentHeight(for: getWatercraftDetailsInputs())
            return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight)
        case .JourneyDetails:
            return estimateJourneyDetailsCellHeight(for: indexPath)
        case .InspectionDetails:
            let estimatedContentHeight = estimateBasicCellContentHeight(for: getInspectionDetailsInputs())
            return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight)
        case .GeneralComments:
            let estimatedContentHeight = estimateBasicCellContentHeight(for: getCommentSectionInputs())
            return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight)
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
            cell.setup(with: journeyDetails.previousWaterBodies[itemsIndex])
            return cell
        case .DestinationWaterBody:
            let cell = getDestinationWaterBodyCell(indexPath: indexPath)
            let itemsIndex: Int = indexPath.row - (journeyDetails.previousWaterBodies.count + 2)
            cell.setup(with: journeyDetails.destinationWaterBodies[itemsIndex])
            return cell
        case .AddPreviousWaterBody:
            let cell = getButtonCell(indexPath: indexPath)
            cell.setup(with: "Add Prveious Water Body") {
                self.journeyDetails.previousWaterBodies.append([])
                self.collectionView.reloadSections(IndexSet(integer: indexPath.section))
            }
            return cell
        case .AddDestinationWaterBody:
            let cell = getButtonCell(indexPath: indexPath)
            cell.setup(with: "Add Destination Water Body") {
                self.journeyDetails.destinationWaterBodies.append([])
                self.collectionView.reloadSections(IndexSet(integer: indexPath.section))
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
            return CGSize(width: width, height: 152)
        case .DestinationWaterBody:
            return CGSize(width: width, height: 152)
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
    
    // Calculates the estimated height needed to display an array of input items
    private func estimateBasicCellContentHeight(for items: [InputItem]) -> CGFloat {
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
                itemWidth = 33.3
            case .Forth:
                itemWidth = 25
            }
            // If the new row witdh + current row width exceeds 100, item will be in the next row
            if (widthCounter + (itemWidth + assumedCellSpacing)) > 100 {
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
        return computedHeight
    }
}
