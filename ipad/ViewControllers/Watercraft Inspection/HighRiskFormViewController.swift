//
//  HighRiskFormViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-12.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

public enum HighRiskFormSection: Int, CaseIterable {
    case BasicInformation = 0
    case Inspection
    case InspectionOutcomes
    case GeneralComments
}

class HighRiskFormViewController: BaseViewController {
    
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Constants
    private let collectionCells = [
        "BasicCollectionViewCell",
    ]
    
    // MARK: Variables
    public var model: HighRiskAssessmentModel? = nil
    public var isEditable: Bool = true
    var showFullForm: Bool = false
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
    
    func setup(with model: HighRiskAssessmentModel, editable: Bool) {
        self.model = model
        self.showFullForm = model.cleanDrainDryAfterInspection == false
        self.isEditable = editable
        self.styleNavBar()
    }
    
    private func addListeners() {
        NotificationCenter.default.removeObserver(self, name: .InputItemValueChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: .ShouldResizeInputGroup, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.inputItemValueChanged(notification:)), name: .InputItemValueChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.shouldResizeInputGroup(notification:)), name: .ShouldResizeInputGroup, object: nil)
    }
    
    // MARK: Notification functions
    @objc func shouldResizeInputGroup(notification: Notification) {
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    @objc func inputItemValueChanged(notification: Notification) {
        guard let item: InputItem = notification.object as? InputItem else {return}
        formResult[item.key] = item.value.get(type: item.type)
        // Set value in Realm object
        
        if let m = model {
            // TODO: needs cleanup for nil case
            m.set(value: item.value.get(type: item.type) as Any, for: item.key)
        }
        
        if item.key == "cleanDrainDryAfterInspection" {
            // If is NOT passport holder, Show full form
            let fieldValue = item.value.get(type: item.type) as? Bool ?? nil
            if fieldValue == false {
                self.showFullForm = true
            } else {
                self.showFullForm = false
            }
            self.collectionView.reloadData()
        }
    }
    
    private func style() {
        setNavigationBar(hidden: false, style: UIBarStyle.black)
        self.styleNavBar()
    }
    
    private func styleNavBar() {
        guard let navigation = self.navigationController else { return }
        self.title = "High Risk Assessment"
        navigation.navigationBar.isTranslucent = false
        navigation.navigationBar.tintColor = .white
        navigation.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        setGradiantBackground(navigationBar: navigation.navigationBar)
        if let _ = self.model, isEditable == true {
            setRightNavButtonTo(type: .save)
        }
        
    }
    
    private func setRightNavButtonTo(type: UIBarButtonItem.SystemItem) {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: type, target: self, action: #selector(self.action(sender:)))
    }
    
    // Navigation bar right button action
    @objc func action(sender: UIBarButtonItem) {
        self.dismissKeyboard()
        self.navigationController?.popViewController(animated: true)
    }
}

extension HighRiskFormViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
        //        guard let sectionType = HighRiskFormSection(rawValue: Int(section)) else {return 0}
        return 1
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if self.showFullForm == true {
            return HighRiskFormSection.allCases.count
        } else {
            return 2
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = HighRiskFormSection(rawValue: Int(indexPath.section)), let model = self.model else {
            return UICollectionViewCell()
        }
        let sectionTitle = "\(sectionType)".convertFromCamelCase()
        let cell = getBasicCell(indexPath: indexPath)
        cell.setup(title: sectionTitle, input: model.getInputputFields(for: sectionType, editable: isEditable), delegate: self)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let sectionType = HighRiskFormSection(rawValue: Int(indexPath.section)), let model = self.model else {
            return CGSize(width: 0, height: 0)
        }
        
        let estimatedContentHeight = InputGroupView.estimateContentHeight(for: model.getInputputFields(for: sectionType))
        return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight + 80)
    }
}
