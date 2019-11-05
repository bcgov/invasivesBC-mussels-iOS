//
//  WatercraftInspectionViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-04.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

public enum FromSection: Int, CaseIterable {
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
    ]
    
    // MARK: Variables
    private var isEditable: Bool = true
    
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
//        navigation.navigationBar.barTintColor = Colors.primary
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return FromSection.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = FromSection(rawValue: Int(indexPath.row)) else {
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
            let cell = getBasicCell(indexPath: indexPath)
            cell.setup(title: "hello", input: getWatercraftDetailsInputs(), delegate: self)
            return cell
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
        guard let sectionType = FromSection(rawValue: Int(indexPath.row)) else {
            return CGSize(width: 0, height: 0)
        }
        switch sectionType {
        case .BasicInformation:
            return CGSize(width: self.collectionView.frame.width, height: 150)
        case .WatercraftDetails:
            return CGSize(width: self.collectionView.frame.width, height: 230)
        case .JourneyDetails:
            return CGSize(width: self.collectionView.frame.width, height: 230)
        case .InspectionDetails:
            return CGSize(width: self.collectionView.frame.width, height: 230)
        case .GeneralComments:
            return CGSize(width: self.collectionView.frame.width, height: 230)
        }
    }
}
