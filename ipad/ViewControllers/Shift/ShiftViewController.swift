//
//  ShiftViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-19.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit


// MARK: Enums
private enum ShiftOverviewSectionRow: Int, CaseIterable {
    case Header
    case Inspections
    case Blowbys
}

private enum BlowbyOverviewSectionRow: Int, CaseIterable {
    case Header
    case Blowbys
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
        "BlowbyTableCollectionViewCell",
        "ShiftInformationHeaderCollectionViewCell",
        "ShiftBlowbysHeaderCollectionViewCell",
    ]
    
    // MARK: Varialbes
    var model: ShiftModel?
    var showShiftInfo: Bool = true
    var isEditable: Bool = true
    private var inspection: WatercraftInspectionModel?
    private var blowby: BlowbyModel?
    
    // MARK: Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    deinit {
        print("De-init shift")
    }
    
    // MARK: Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateStatuses();
        setupCollectionView()
        self.collectionView.reloadData()
        addListeners()
    }
    /// Iterates through inspections checking formDidValidate. If any form does validate, modifies all appropraite statuses to `.Errors`
    private func updateStatuses() {
        guard let model = self.model else { return }
        if(model.status != "Completed"){
            if (model.inspections.allSatisfy(){$0.formDidValidate}){
                model.set(status: .Draft)
                model.inspections.forEach { inspection in
                    inspection.set(status: .Draft)
                }
            } else {
                model.set(status: .Errors)
                model.inspections.forEach { inspection in
                    inspection.set(status: inspection.formDidValidate ? .Draft : .Errors)
                }
            }
        }
    }
    private func addListeners() {
        NotificationCenter.default.removeObserver(self, name: .TableButtonClicked, object: nil)
        NotificationCenter.default.removeObserver(self, name: .InputItemValueChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: .BlowbyDeleteClicked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.tableButtonClicked(notification:)), name: .TableButtonClicked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.inputItemValueChanged(notification:)), name: .InputItemValueChanged, object: nil)
    }

  
  /// Handler for when 'Add Blowby' is pressed. Brings up the shift modal, and refreshing the screen on submit action
  @objc func addBlowByClicked() {
      let blowbyModal: NewBlowbyModal = NewBlowbyModal.fromNib()
      blowbyModal.onSubmit = { [weak self] in
          // Refresh the screen when data is submitted
          self?.refreshScreen()
      }
      guard let currentShiftModel = model else { return }
      blowbyModal.initialize(shift: currentShiftModel, delegate: self, onStart: { [weak self] (model) in
        guard self != nil else { return }
      }) {
          // Cancelled
      }
  }

  func refreshScreen(){
    self.view.setNeedsDisplay()
    self.viewWillAppear(true)
  }

    func setup(model: ShiftModel) {
        self.model = model
        self.isEditable = [.Draft, .PendingSync, .Errors].contains(model.getStatus())
        if model.getStatus() == .PendingSync {
            model.set(shouldSync: false)
            for inspection in model.inspections {
                inspection.set(shouldSync: false)
            }
            Alert.show(title: "Changed to draft", message: "Status changed to draft. tap submit when you've made your changes.")
        }
        
      if [.Draft, .Errors].contains(model.getStatus()) {
            // make sure inspections are editable.
            for inspection in model.inspections {
                inspection.set(shouldSync: false)
            }
        }
        self.styleNavBar()
    }
    
    // MARK: Actions
    // Navigation bar right button action
    @objc func didTapDeleteButton(sender: UIBarButtonItem) {
        guard let model = self.model else {return}
        self.dismissKeyboard()
        Alert.show(title: "Deleting Shift", message: "Would you like to delete this shift?", yes: { [weak self] in
            guard let _self = self else {return}
            // Delete Children
            for inspection in model.inspections {
                RealmRequests.deleteObject(inspection)
            }
            // Delete main object
            RealmRequests.deleteObject(model)
            _self.navigationController?.popViewController(animated: true)
        }) {
            return
        }
    }
    
  @objc func didTapBlowbyToggle(blowbyToEdit: BlowbyModel){
    Alert.show(title: "Row tapped", message: "Action continues")
  }
  
  
    /// Handler for Edit button in Blowby table section. Brings up the modal with the existing Blowby so user can submit new data
    /// - Parameter blowbyToEdit: Blowby to populate the view, allowing editing to occur on the model
    @objc func didTapEditBlowbyButton(blowbyToEdit: BlowbyModel) {
      let blowbyModal: NewBlowbyModal = NewBlowbyModal.fromNib()
      blowbyModal.onSubmit = { [weak self] in
          // Refresh the screen when data is submitted
          self?.refreshScreen()
      }
      guard let currentShiftModel = model else { return }
      blowbyModal.initialize(shift: currentShiftModel, newBlowby: blowbyToEdit, delegate: self, onStart: { [weak self] (model) in
        guard self != nil else { return }
      }) {
          // Canceled
      }
    }
  
  /// Handler to delete a Blowby from the Shift
  /// - Parameter blowbyToDelete: Instance of Blowby model that will be removed via realm
  @objc func deleteBlowby(blowbyToDelete: BlowbyModel) {
      guard let model = self.model else { return }
      self.dismissKeyboard()
      model.deleteBlowby(blowbyToDelete: blowbyToDelete);
      self.refreshScreen()
  }

    @objc func completeAction(sender: UIBarButtonItem) {
        guard let model = self.model else { return }
        self.dismissKeyboard()

        self.updateStatuses()
        // if can submit
        var alertMessage = "This shift and the inspections will be uploaded when possible"
        if model.shiftStartDate < Calendar.current.startOfDay(for: Date()) {
            alertMessage += "\n\n 🔵 You've entered a date that occurred before today. If this was intentional, no problem! Otherwise, please double-check the entered date: \n\(model.shiftStartDate.stringShort())"
        }
        if model.isOvernightShift() {
            alertMessage += "\n\n 🔵 You've entered an overnight shift. This shift will carry over to the next day. If this was intentional, no problem! Otherwise, please double-check the entered shift times. \n"
        }
        
        if canSubmit() && (model.inspections.allSatisfy({ $0.formDidValidate })) {
            let alert = UIAlertController(title: "Are you sure?", message: alertMessage, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                
                // First navigate
                strongSelf.navigationController?.popViewController(animated: true)
                
                // Then update model after a longer delay to ensure view hierarchy is ready
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    model.set(shouldSync: true)
                    for inspection in model.inspections {
                        inspection.set(shouldSync: true)
                    }
                }
            }))
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel))
            self.present(alert, animated: true)
        } else {
            Alert.show(title: "Incomplete", message: validationMessage())
        }
    }
    // Table Button clicked
    @objc func tableButtonClicked(notification: Notification) {
        guard let actionModel = notification.object as? TableClickActionModel else {return}
        
        if actionModel.buttonName.lowercased() == "edit", let blowbyModel = actionModel.object as? BlowbyModel {
            didTapEditBlowbyButton(blowbyToEdit: blowbyModel);
        }
        
        if let inspectionModel = actionModel.object as? WatercraftInspectionModel {
            nagivateToInspection(object: inspectionModel, editable: isEditable)
        }
        
        return;
    }
    
    func nagivateToInspection(object: WatercraftInspectionModel?, editable: Bool) {
        self.inspection = object
        self.performSegue(withIdentifier: "showWatercraftInspectionForm", sender: self)
    }
    
    // MARK: Input Item Changed
    @objc func inputItemValueChanged(notification: Notification) {
        guard let item: InputItem = notification.object as? InputItem else { return }
        
        // Handle station selection changes
        if item.key.lowercased() == "station" {
            // Trigger form reload to update dependencies
            self.collectionView.reloadData()
        }
        
        // Update model
        if let model = self.model {
            model.set(value: item.value.get(type: item.type) as Any, for: item.key)
        }
    }
    
    // MARK: - Navigate to Inspection
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let inspectionVC = segue.destination as? WatercraftInspectionViewController, let inspectionModel = self.inspection {
            inspectionVC.setup(model: inspectionModel)
        }
    }
    
    // MARK: Style
    private func style() {
        setNavigationBar(hidden: false, style: UIBarStyle.black)
        styleCard(layer: containerView.layer)
        styleNavBar()
    }
    
    private func styleNavBar() {
        guard let navigation = self.navigationController else { return }
        self.title = "Shift Overview"
        navigation.navigationBar.isTranslucent = false
        navigation.navigationBar.tintColor = .white
        navigation.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        setGradiantBackground(navigationBar: navigation.navigationBar)
        if let model = self.model, [.Draft, .Errors].contains(model.getStatus()) {
            setRightNavButtons()
        }
    }
    
    private func setRightNavButtons() {
        let deleteButton = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(self.didTapDeleteButton(sender:)))
        let saveButton = UIBarButtonItem(title: "Submit", style: .done, target: self, action: #selector(self.completeAction(sender:)))
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        navigationItem.setRightBarButtonItems([saveButton, spacer, deleteButton], animated: true)
    }


    // MARK: Validation
    func canSubmit() -> Bool {
        return validationMessage().isEmpty
    }
    
    func validationMessage() -> String {
        var messages: [String] = []
        guard let model = self.model else { return "" }
        
        // Group validation messages by category
        
        // Shift Time Validations
        if model.startTime.isEmpty {
            messages.append("⏰ Shift Start time is required")
        }
        
        if model.endTime.isEmpty {
            messages.append("⏰ Shift End time is required")
        }
        
        // Inspection Count Validations
        if model.inspections.count > 0 && model.boatsInspected == false {
            messages.append("⚠️ Inspection count mismatch: You indicated no boats were inspected, but inspections exist")
        }
        
        if model.inspections.count < 1 && model.boatsInspected == true {
            messages.append("⚠️ Inspection count mismatch: You indicated boats were inspected but no inspections are recorded")
        }
        
        // Station Validations
        if model.station.isEmpty {
            messages.append("📍 Station selection is required")
        }

        if model.stationComments.isEmpty && ShiftModel.stationRequired(model.station) {
            messages.append("📍 Station information is required")
        }
        
        // Inspection Detail Validations
        for (index, inspection) in model.inspections.enumerated() {
            if inspection.inspectionTime.isEmpty {
                messages.append("🕒 Inspection #\(index + 1): Time of inspection is required")
            }
            
            // Previous Waterbody Validations
            if (((inspection.unknownPreviousWaterBody || inspection.previousDryStorage || inspection.commercialManufacturerAsPreviousWaterBody) && inspection.previousMajorCities.isEmpty)) {
                messages.append("🌊 Inspection #\(index + 1): Previous waterbody requires closest major city")
            }
            
            // Destination Waterbody Validations
            if (inspection.unknownDestinationWaterBody || 
                inspection.commercialManufacturerAsDestinationWaterBody || 
                inspection.destinationDryStorage) && inspection.destinationMajorCities.isEmpty {
                messages.append("🎯 Inspection #\(index + 1): Destination waterbody requires closest major city")
            }

            // High Risk Assessment Validations
            for (riskIndex, highRisk) in inspection.highRiskAssessments.enumerated() {
                if highRisk.sealIssued && highRisk.sealNumber <= 0 {
                    messages.append("🏷️ Inspection #\(index + 1) Risk #\(riskIndex + 1): Seal number is required")
                }
                
                if highRisk.decontaminationOrderIssued && highRisk.decontaminationOrderNumber <= 0 {
                    messages.append("📄 Inspection #\(index + 1) Risk #\(riskIndex + 1): Decontamination order number is required")
                }
            }
        }

        // Form Validation Status
        let invalidInspections = model.inspections.filter { !$0.formDidValidate }
        if !invalidInspections.isEmpty {
            messages.append("❌ One or more inspections contain validation errors")
        }

       if !messages.isEmpty {
           model.set(status: .Errors)
       }
        
        return messages.joined(separator: "\n\n")
    }
    
    func createTestModel() {
        let model = ShiftModel()
        
        // Create dummy inspections
        let inspection1 = WatercraftInspectionModel()
        inspection1.remoteId = 65100
        inspection1.inspectionTime = "16.00"
        inspection1.shouldSync = true
        
        // Create dummy inspections
        let inspection2 = WatercraftInspectionModel()
        inspection2.remoteId = 65102
        inspection2.inspectionTime = "8.00"
        inspection2.shouldSync = false
        
        model.inspections.append(inspection1)
        model.inspections.append(inspection2)
        
        self.model = model
    }
}

// MARK: CollectionView
extension ShiftViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private func setupCollectionView() {
        collectionView.accessibilityLabel = "shiftform"
        collectionView.accessibilityValue = "shiftform"
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
  func getShiftBlowbysHeaderCollectionViewCell(indexPath: IndexPath) -> ShiftBlowBysHeaderCollectionViewCell {
    return collectionView!.dequeueReusableCell(withReuseIdentifier: "ShiftBlowBysHeaderCollectionViewCell", for: indexPath as IndexPath) as! ShiftBlowBysHeaderCollectionViewCell;
  }
  
    func getBlowbyTableCell(indexPath: IndexPath) -> BlowbyTableCollectionViewCell {
      return collectionView!.dequeueReusableCell(withReuseIdentifier: "BlowbyTableCollectionViewCell", for: indexPath as IndexPath) as! BlowbyTableCollectionViewCell
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
            cell.setup(object: model, callback: {[weak self] in
                guard let strongSelf = self else {return}
                if strongSelf.isEditable {
                    strongSelf.nagivateToInspection(object: model.addInspection(), editable: strongSelf.isEditable)
                }
            })
            return cell
        case .Inspections:
            let cell = getInspectionsTableCell(indexPath: indexPath)
            cell.setup(object: model)
            return cell
        case .Blowbys:
            let cell = getBlowbyTableCell(indexPath: indexPath)
          cell.setup(object: model, callback: {[weak self] in
            guard let strongSelf = self else {return}
            if strongSelf.isEditable {
              strongSelf.addBlowByClicked()
            }
          })
            return cell
        }
    }
    
    func getShiftInformationSectionRow(indexPath: IndexPath) -> UICollectionViewCell {
        guard let rowType = ShiftInformationSectionRow(rawValue: Int(indexPath.row)), let model = self.model else {return UICollectionViewCell()}
        switch rowType {
        case .Header:
            let cell = getShiftInformationHeaderCell(indexPath: indexPath)
            cell.setup(isHidden: !showShiftInfo) { [weak self] in
                guard let strongSelf = self else {return}
                // OnClick
                strongSelf.showShiftInfo = !strongSelf.showShiftInfo
                strongSelf.collectionView.reloadSections(IndexSet(integer: ShiftViewSection.Information.rawValue))
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
    
  func getBlowbyOverviewSectionRow(indexPath: IndexPath) -> UICollectionViewCell {
      guard let rowType = BlowbyOverviewSectionRow(rawValue: Int(indexPath.row)), let model = self.model else {return UICollectionViewCell() }
      switch rowType {
      case .Header:
          let cell = getShiftBlowbysHeaderCollectionViewCell(indexPath: indexPath)
          cell.setup(object: model, callback: {[weak self] in
              guard let strongSelf = self else {return}
          })
          return cell
      case .Blowbys:
          let cell = getBlowbyTableCell(indexPath: indexPath)
          cell.setup(object: model)
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
        let fullWidth = self.collectionView.frame.width
        switch row {
        case .Header:
            return CGSize(width: fullWidth, height: 62)
        case .Inspections:
            let height = InspectionsTableCollectionViewCell.getContentHeight(for: model)
            return CGSize(width: fullWidth, height: height)
        case .Blowbys:
            let height = BlowbyTableCollectionViewCell.getContentHeight(for: model)
            return CGSize(width: fullWidth, height: height);
        }
    }
    
    fileprivate func getSizeForShiftInfo(row: ShiftInformationSectionRow?) -> CGSize {
        guard let row = row else {return CGSize(width: 0, height: 0)}
        guard let model = model else {return CGSize(width: 0, height: 0)}
        let fullWdtih = self.collectionView.frame.width
        switch row {
        case .Header:
            return CGSize(width: fullWdtih, height: 35)
        case .StartShift:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: ShiftFormHelper.getShiftStartFields(for: model, editable: true))
            return CGSize(width: fullWdtih, height: estimatedContentHeight + 110)
        case .EndShift:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: ShiftFormHelper.getShiftEndFields(for: model, editable: true))
            return CGSize(width: fullWdtih, height: estimatedContentHeight + 110)
        }
    }
}
