//
//  WatercraftInspectionViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-04.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

// MARK: Ennums
private enum JourneyDetailsSectionRow {
    case Header
    case PreviousWaterBody
    case DestinationWaterBody
    case PreviousMajorCity
    case DestinationMajorCity
    case AddPreviousWaterBody
    case AddDestinationWaterBody
    case PreviousHeader
    case DestinationHeader
    case Divider
    case Blank
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
        "JourneyHeaderCollectionViewCell",
        "PreviousMajorCityCollectionViewCell",
        "DestinationMajorCityCollectionViewCell",
        "BlankCollectionViewCell"
    ]
    
    // MARK: Variables
    var shiftModel: ShiftModel?
    var model: WatercraftInspectionModel? = nil
    private var showFullInspection: Bool = false
    private var showHighRiskAssessment: Bool = false
    private var showFullHighRiskAssessment = false
    private var isEditable: Bool = true
    
    deinit {
        print("De-init inspection")
    }
    
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
    
    // MARK: Setup
    func setup(model: WatercraftInspectionModel) {
        model.set(value: false, for: "formDidValidate")
        self.model = model
        self.isEditable = [.Draft, .Errors].contains(model.getStatus())
        self.styleNavBar()
        if !model.isPassportHolder || model.launchedOutsideBC || model.isNewPassportIssued {
            self.showFullInspection = true
        }
        
        self.showHighRiskAssessment = shouldShowHighRiskForm()
        self.showFullHighRiskAssessment = shouldShowFullHighRiskForm()
    }
    
    // MARK: High Risk
    func shouldShowHighRiskForm() -> Bool {
        guard let model = self.model else {return false}
        let highRiskFieldKeys = WatercraftInspectionFormHelper.getHighriskAssessmentFieldsFields().map{ $0.key}
        for key in highRiskFieldKeys {
            if model[key] as? Bool == true {
                return true
            }
        }
        if model.cleanDrainDryAfterInspection == true {
            return true
        }
        return false
    }
    
    func shouldShowFullHighRiskForm() -> Bool {
        guard let model = self.model, let highRisk = model.highRiskAssessments.first else {return false}
        return !highRisk.cleanDrainDryAfterInspection
    }
    
    func showHighRiskForm(show: Bool) {
        guard let model = self.model else {
            return
        }
        if show && model.highRiskAssessments.isEmpty {
            let _ = model.addHighRiskAssessment()
        }
        self.showHighRiskAssessment = show
        self.showFullHighRiskAssessment = !(model.highRiskAssessments.first?.cleanDrainDryAfterInspection ?? false)
        self.collectionView.reloadData()
    }
    
    func showFullHighRiskForm(show: Bool) {
        showFullHighRiskAssessment = show
        self.collectionView.reloadData()
    }
    
    // MARK: Listeners
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
        if let model = self.model, [.Draft, .Errors].contains(model.getStatus()) {
            setRightNavButtons()
            setLeftNavButtons()
        }
    }
    
    private func setLeftNavButtons() {
        // Create a UIButton to hold the back icon and text
        let backButton = UIButton(type: .custom)
        backButton.setTitle(" Shift Overview", for: .normal)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        backButton.addTarget(self, action: #selector(didTapBackButton(sender:)), for: .touchUpInside)
        backButton.contentHorizontalAlignment = .left
        backButton.semanticContentAttribute = .forceLeftToRight
        
        backButton.sizeToFit()

        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        
        navigationItem.leftBarButtonItem = backBarButtonItem
    }
    
    private func setRightNavButtons() {
        let deleteIcon = UIImage(systemName: "trash")
        let deleteButton = UIBarButtonItem(image: deleteIcon,  style: .plain, target: self, action: #selector(self.didTapDeleteButton(sender:)))
        
        let saveIcon = UIImage(systemName: "checkmark")
        let saveButton = UIBarButtonItem(image: saveIcon,  style: .plain, target: self, action: #selector(self.didTapCheckmarkButton(sender:)))
        
        navigationItem.rightBarButtonItems = [saveButton, deleteButton]
    }
    
    @objc func didTapBackButton(sender: UIBarButtonItem) {
        self.dismissKeyboard()

        if canSubmit() {
            self.navigationController?.popViewController(animated: true)
        } else {
            Alert.showValidation(title: "Inspection Incomplete", message: validationMessage())
        }
    }
    
    // Navigation bar right button action
    @objc func didTapDeleteButton(sender: UIBarButtonItem) {
        guard let model = self.model else {return}
        self.dismissKeyboard()
        Alert.show(title: "Deleting Inspection", message: "Would you like to delete this inspection?", yes: {[weak self] in
            guard let _self = self else {return}
            // Delete child objects
            for item in model.previousWaterBodies {
                RealmRequests.deleteObject(item)
            }
            for item in model.destinationWaterBodies {
                RealmRequests.deleteObject(item)
            }
            for item in model.highRiskAssessments {
                RealmRequests.deleteObject(item)
            }
            for item in model.previousMajorCities {
                RealmRequests.deleteObject(item)
            }
            for item in model.destinationMajorCities {
                RealmRequests.deleteObject(item)
            }
            // Delete main object
            RealmRequests.deleteObject(model)
            _self.navigationController?.popViewController(animated: true)
        }) {
            return
        }
    }
    
    func canSubmit() -> Bool {
        return validationMessage().isEmpty
    }
    
    /// Enum error cases grouped by sections for clarity
    enum ValidationType {
        // Null Switch Interactions
        case commerciallyHauledInteracted               // Basic Information
        case previousAISKnowledgeInteracted             // Watercraft Details
        case previousInspectionInteracted               // Watercraft Details
        case dreissenidMusselsFoundPreviousInteracted   // Inspection Details
        case k9InspectionInteracted                     // Inspection Details
        case watercraftHasDrainplugsInteracted
        case drainplugRemovedAtInspectionInteracted
        case decontaminationPerformedInteracted         // High Risk Form
        case decontaminationOrderIssuedInteracted       // High Risk Form
        case decontaminationAppendixBInteracted         // High Risk Form
        case sealIssuedInteracted                       // High Risk Form
        case quarantinePeriodIssuedInteracted           // High Risk Form
        
        // Basic
        case inspectionTime
        case numberOfPeopleInParty
        case isNoWatercraftTypeSelected
        
        // Watercraft Details
        case previousAISKnowledge
        case previousInspectionSource
        case previousInspectionDays
        
        // Journey Details
        case previousWaterBodies
        case numberOfDaysOut
        case previousMajorCities
        case destinationWaterBodies
        case destinationMajorCities
        case prevOtherWaterbodyNoCity
        case destOtherWaterbodyNoCity
        
        // Inspection Outcomes (High Risk form)
        case decontaminationPerformed
        case decontaminationOrderNumber
        case decontaminationOrderReason
        case sealNumber
    }

    /// Enum error messages grouped by sections for clarity
    enum ValidationError: String {
        // Null Switch Interaction errors
        case errorCommerciallyHauledInteracted = "Watercraft/equipment commercially hauled."
        case errorPreviousAISKnowledgeInteracted = "Previous Knowledge of AIS or Clean, Drain, Dry."
        case errorPreviousInspectionInteracted = "Previous Inspection and/or Agency Notification."
        case errorDreissenidMusselsFoundPreviousInteracted = "Dreissenid mussels found during previous inspection and FULL decontamination already completed/determined to be CDD."
        case errorK9InspectionInteracted = "K9 Inspection Performed."
        case errorDecontaminationPerformedInteracted = "Decontamination performed."
        case errorDecontaminationOrderIssuedInteracted = "Decontamination order issued."
        case errorDecontaminationAppendixBInteracted = "Appendix B filled out field."
        case errorSealIssuedInteracted = "Seal issued or existing seal field."
        case errorQuarantinePeriodIssuedInteracted = "Quarantine period issued field."
        case errorWatercraftHasDrainplugsInteracted = "Watercraft has Drain plugs field."
        case errorDrainplugRemovedAtInspectionInteracted = "Drain plug removed field."
        
        // Basic
        case errorInspectionTime = "Time of Inspection."
        case errorNumberOfPeopleInParty = "Number of people in the party."
        case errorIsNoWatercraftTypeSelected = "Watercraft Type needed:\n  ⛵ Non-Motorized\n  ⛵ Simple\n  ⛵ Complex\n  ⛵ Very Complex"
        
        // Watercraft Details
        case errorPreviousAISKnowledge = "Source for Previous Knowledge of AIS or Clean, Drain, Dry."
        case errorPreviousInspectionSource = "Source for Previous Inspection and/or Agency Notification."
        case errorPreviousInspectionDays = "No. of Days for Previous Inspection and/or Agency Notification."
        
        // Journey Details
        case errorPreviousWaterBodies = "Previous Waterbody\n(or toggle New, Unknown, or Stored)."
        case errorNumberOfDaysOut = "Number of days out of waterbody."
        case errorPreviousMajorCities = "Closest Major City for Previous Waterbody."
        case errorDestinationWaterBodies = "Destination Waterbody\n(or toggle New, Unknown, or Stored)."
        case errorDestinationMajorCities = "Closest Major City for Destination Waterbody."
        case errorPrevOtherWaterbodyNoCity = "To improve identification for the 'Other' Waterbody, add a Previous Closest Major City."
        case errorDestOtherWaterbodyNoCity = "To improve identification for the 'Other' Waterbody, add a Destination Closest Major City."
        // Inspection Outcomes (High Risk form)
        case errorDecontaminationPerformed = "Record of Decontamination number."
        case errorDecontaminationOrderNumber = "Decontamination order number."
        case errorDecontaminationOrderReason = "Reason for issuing a decontamination order."
        case errorSealNumber = "Seal #"
    }
    
    enum Section: String {
        case basicInformation = " BASIC INFORMATION "
        case watercraftDetails = " WATERCRAFT DETAILS "
        case journeyDetails = " JOURNEY DETAILS "
        case inspectionDetails = " INSPECTION DETAILS "
        case inspectionOutcomes = " INSPECTION OUTCOMES "
    }

    /// Validation struct for the errors, their messages, and the condition where they should be called in validation process
    struct Validation {
        var type: ValidationType
        var errorMessage: ValidationError
        var condition: Bool
        var section: Section
    }

    
    /// Performs validation checks on the Inspection, separating the distinct sections
    /// of Basic Information, Watercraft Details, Journey Details, Inspection Details,
    /// and Inspection Outcomes (High Risk form). Checks specific conditions
    /// and generates error messages for failed validations within each section.
    ///  
    /// - Returns: String of validation messages to display in the alert
    func validationMessage() -> String {
        var validationErrors: [(section: Section, errors: [String])] = [
            (.basicInformation, []),
            (.watercraftDetails, []),
            (.journeyDetails, []),
            (.inspectionDetails, []),
            (.inspectionOutcomes, [])
        ]
        guard let model = self.model else { return "" }
        
        // The inspection form only appears if Passport is new, or if the toggle
        // "Launched outside BC/AB..." is toggled ON. Otherwise, we don't need to
        // check the inspection fields below because they will be hidden.
        let isPassportHolderNewOrLaunched = !model.isPassportHolder || (model.isPassportHolder && (model.launchedOutsideBC || model.isNewPassportIssued))
        
        // User should have entered at least one watercraft type
        let isNoWatercraftTypeSelected =
          model.nonMotorized == 0 &&
          model.simple == 0 &&
          model.complex == 0 &&
          model.veryComplex == 0;
        
        // PREVIOUS WATERBODY
        // Commercial, unknown waterbody, AND previously stored are false
        let isPreviousWaterbody = !model.unknownPreviousWaterBody
            && !model.commercialManufacturerAsPreviousWaterBody
            && !model.previousDryStorage
        
        // DESTINATION WATERBODY
        // Commercial, unknown waterbody, AND will be stored are false
        let isDestinationWaterbody = !model.unknownDestinationWaterBody
            && !model.commercialManufacturerAsDestinationWaterBody
            && !model.destinationDryStorage
        
        // Set values for any missing "Number of days out of waterbody" fields, if they exist
        var previousNumberOfDays: String = ""
        if isPassportHolderNewOrLaunched && !model.previousWaterBodies.isEmpty {
            for prev in model.previousWaterBodies {
                previousNumberOfDays = prev.numberOfDaysOut
            }
        }
        
        let prevHasNonEmptyOtherWaterbody = model.previousWaterBodies.contains { !$0.otherWaterbody.isEmpty }
        let destHasNonEmptyOtherWaterbody = model.destinationWaterBodies.contains { !$0.otherWaterbody.isEmpty }
        
        // Set values for High Risk form, if it exists
        var highRiskDecontaminationPerformedInteracted: Bool = false
        var highRiskDecontaminationOrderIssuedInteracted: Bool = false
        var highRiskDecontaminationAppendixBInteracted: Bool = false
        var highRiskSealIssuedInteracted: Bool = false
        var highRiskQuarantinePeriodIssuedInteracted: Bool = false
        
        var highRiskDecontaminationPerformed: Bool = false
        var highRiskDecontaminationReference: String = ""
        var highRiskDecontaminationOrderIssued: Bool = false
        var highRiskDecontaminationOrderNumber: Int = 0
        var highRiskDecontaminationOrderReason: String = ""
        var highRiskSealIssued: Bool = false
        var highRiskSealNumber: Int = 0
        
        if isPassportHolderNewOrLaunched, let highRisk = model.highRiskAssessments.first {
            // Null Switches
            highRiskDecontaminationPerformedInteracted = highRisk.decontaminationPerformedInteracted
            highRiskDecontaminationOrderIssuedInteracted = highRisk.decontaminationOrderIssuedInteracted
            highRiskDecontaminationAppendixBInteracted = highRisk.decontaminationAppendixBInteracted
            highRiskSealIssuedInteracted = highRisk.sealIssuedInteracted
            highRiskQuarantinePeriodIssuedInteracted = highRisk.quarantinePeriodIssuedInteracted
            // Other form fields (if "Yes" is selected)
            highRiskDecontaminationPerformed = highRisk.decontaminationPerformed
            highRiskDecontaminationReference = highRisk.decontaminationReference
            highRiskDecontaminationOrderIssued = highRisk.decontaminationOrderIssued
            highRiskDecontaminationOrderNumber = highRisk.decontaminationOrderNumber
            highRiskDecontaminationOrderReason = highRisk.decontaminationOrderReason
            highRiskSealIssued = highRisk.sealIssued
            highRiskSealNumber = highRisk.sealNumber
        }

        /// This is where we write out the conditional logic for when the validation
        /// e.g. if the previousAISKnowledgeSource field isEmpty, then the validation will fail
        /// and the corresponding errorMessage will be shown when attempting to submit
        let validationItems: [Validation] = [
            // Null Switch validation
            Validation(
              type: .watercraftHasDrainplugsInteracted,
              errorMessage: .errorWatercraftHasDrainplugsInteracted,
              condition: isPassportHolderNewOrLaunched && !model.watercraftHasDrainplugsInteracted,
              section: .inspectionDetails
            ),
            Validation(
              type: .drainplugRemovedAtInspectionInteracted,
              errorMessage: .errorDrainplugRemovedAtInspectionInteracted,
              condition: model.watercraftHasDrainplugs && !model.drainplugRemovedAtInspectionInteracted,
              section: .inspectionDetails
            ),
            Validation(
                type: .commerciallyHauledInteracted,
                errorMessage: .errorCommerciallyHauledInteracted,
                condition: !model.commerciallyHauledInteracted,
                section: .watercraftDetails
            ),
            Validation(
                type: .previousAISKnowledgeInteracted,
                errorMessage: .errorPreviousAISKnowledgeInteracted,
                condition: !model.previousAISKnowledeInteracted,
                section: .watercraftDetails
            ),
            Validation(
                type: .previousInspectionInteracted,
                errorMessage: .errorPreviousInspectionInteracted,
                condition: !model.previousInspectionInteracted,
                section: .watercraftDetails
            ),
            Validation(
                type: .dreissenidMusselsFoundPreviousInteracted,
                errorMessage: .errorDreissenidMusselsFoundPreviousInteracted,
                condition: isPassportHolderNewOrLaunched
                    && !model.dreissenidMusselsFoundPreviousInteracted,
                section: .inspectionDetails
            ),
            Validation(
                type: .k9InspectionInteracted,
                errorMessage: .errorK9InspectionInteracted,
                condition: !model.k9InspectionInteracted,
                section: .inspectionDetails
            ),
            Validation(
                type: .decontaminationPerformedInteracted,
                errorMessage: .errorDecontaminationPerformedInteracted,
                condition: !highRiskDecontaminationPerformedInteracted,
                section: .inspectionOutcomes
            ),
            Validation(
                type: .decontaminationOrderIssuedInteracted,
                errorMessage: .errorDecontaminationOrderIssuedInteracted,
                condition: !highRiskDecontaminationOrderIssuedInteracted,
                section: .inspectionOutcomes
            ),
            Validation(
                type: .decontaminationAppendixBInteracted,
                errorMessage: .errorDecontaminationAppendixBInteracted,
                condition: !highRiskDecontaminationAppendixBInteracted,
                section: .inspectionOutcomes
            ),
            Validation(
                type: .sealIssuedInteracted,
                errorMessage: .errorSealIssuedInteracted,
                condition: !highRiskSealIssuedInteracted,
                section: .inspectionOutcomes
            ),
            Validation(
                type: .quarantinePeriodIssuedInteracted,
                errorMessage: .errorQuarantinePeriodIssuedInteracted,
                condition: !highRiskQuarantinePeriodIssuedInteracted,
                section: .inspectionOutcomes
            ),
            
            // Basic Information validation
            Validation(
                type: .inspectionTime,
                errorMessage: .errorInspectionTime,
                condition: model.inspectionTime.isEmpty,
                section: .basicInformation
            ),
            Validation(
                type: .isNoWatercraftTypeSelected,
                errorMessage: .errorIsNoWatercraftTypeSelected,
                condition: isNoWatercraftTypeSelected,
                section: .basicInformation
            ),
            
            // Watercraft Details validation
            Validation(
                type: .numberOfPeopleInParty,
                errorMessage: .errorNumberOfPeopleInParty,
                condition: model.numberOfPeopleInParty < 1,
                section: .watercraftDetails
            ),
            Validation(
                type: .previousAISKnowledge,
                errorMessage: .errorPreviousAISKnowledge,
                condition: model.previousAISKnowledeInteracted
                    && model.previousAISKnowlede
                    && model.previousAISKnowledeSource.isEmpty,
                section: .watercraftDetails
            ),
            Validation(
                type: .previousInspectionSource,
                errorMessage: .errorPreviousInspectionSource,
                condition: model.previousInspectionInteracted
                    && model.previousInspection
                    && model.previousInspectionSource.isEmpty,
                section: .watercraftDetails
            ),
            Validation(
                type: .previousInspectionDays,
                errorMessage: .errorPreviousInspectionDays,
                condition: model.previousInspectionInteracted
                    && model.previousInspection
                    && model.previousInspectionDays.isEmpty,
                section: .watercraftDetails
            ),
            
            // Journey Details validation
            // Note: Prev and Dest Major City are required on all otherWaterbody submissions
            Validation(
                type: .previousWaterBodies,
                errorMessage: .errorPreviousWaterBodies,
                condition: isPreviousWaterbody
                    && model.previousWaterBodies.isEmpty,
                section: .journeyDetails
            ),
            Validation(
                type: .previousMajorCities,
                errorMessage: .errorPreviousMajorCities,
                condition: !isPreviousWaterbody
                    && model.previousMajorCities.isEmpty,
                section: .journeyDetails
            ),
            Validation(
                type: .destinationWaterBodies,
                errorMessage: .errorDestinationWaterBodies,
                condition: isDestinationWaterbody
                    && model.destinationWaterBodies.isEmpty,
                section: .journeyDetails
            ),
            Validation(
                type: .destinationMajorCities,
                errorMessage: .errorDestinationMajorCities,
                condition: !isDestinationWaterbody
                    && model.destinationMajorCities.isEmpty,
                section: .journeyDetails
            ),
            Validation(
                type: .numberOfDaysOut,
                errorMessage: .errorNumberOfDaysOut,
                condition: !model.previousWaterBodies.isEmpty
                    && previousNumberOfDays.isEmpty,
                section: .journeyDetails
            ),
            Validation(
                type: .prevOtherWaterbodyNoCity,
                errorMessage: .errorPrevOtherWaterbodyNoCity,
                condition: prevHasNonEmptyOtherWaterbody
                    && model.previousMajorCities.isEmpty,
                section: .journeyDetails
            ),
            Validation(
                type: .destOtherWaterbodyNoCity,
                errorMessage: .errorDestOtherWaterbodyNoCity,
                condition: destHasNonEmptyOtherWaterbody
                    && model.destinationMajorCities.isEmpty,
                section: .journeyDetails
            ),
            
            // Inspection Details
            // K9 inspection and time of inspection are the only
            // two fields that persist between Passport and non-Passport
            // so we put inspection time here under the condition it's not
            // a new Passport or "Launched outside BC/AB..."
            Validation(
                type: .inspectionTime,
                errorMessage: .errorInspectionTime,
                condition: !isPassportHolderNewOrLaunched
                    && model.inspectionTime.isEmpty,
                section: .inspectionDetails
            ),
            
            // Inspection Outcomes validation (High Risk form)
            Validation(
                type: .decontaminationPerformed,
                errorMessage: .errorDecontaminationPerformed,
                condition: highRiskDecontaminationPerformed
                    && highRiskDecontaminationReference.isEmpty,
                section: .inspectionOutcomes
            ),
            Validation(
                type: .decontaminationOrderNumber,
                errorMessage: .errorDecontaminationOrderNumber,
                condition: highRiskDecontaminationOrderIssued
                    && highRiskDecontaminationOrderNumber <= 0,
                section: .inspectionOutcomes
            ),
            Validation(
                type: .decontaminationOrderReason,
                errorMessage: .errorDecontaminationOrderReason,
                condition: highRiskDecontaminationOrderIssued
                    && highRiskDecontaminationOrderReason.isEmpty,
                section: .inspectionOutcomes
            ),
            Validation(
                type: .sealNumber,
                errorMessage: .errorSealNumber,
                condition: highRiskSealIssued
                && highRiskSealNumber <= 0,
                section: .inspectionOutcomes
            ),
        ]

        // Iterates through the validationItems and checks conditions for any failures
        // Aggregates the error messages into their respective arrays
        for validation in validationItems {
            switch validation.section {
            case .basicInformation:
                if isPassportHolderNewOrLaunched && validation.condition {
                    validationErrors[0].errors.append(validation.errorMessage.rawValue)
                }
            case .watercraftDetails:
                if isPassportHolderNewOrLaunched && validation.condition {
                    validationErrors[1].errors.append(validation.errorMessage.rawValue)
                }
            case .journeyDetails:
                if isPassportHolderNewOrLaunched && validation.condition {
                    validationErrors[2].errors.append(validation.errorMessage.rawValue)
                }
            case .inspectionDetails:
                // isPassportHolderNewOrLaunched only applies to dreissenidMusselsFound,
                // not to k9Inspection, so added in condition in Validation above
                if validation.condition {
                    validationErrors[3].errors.append(validation.errorMessage.rawValue)
                }
            case .inspectionOutcomes:
                // Only need to check if highRiskAssessment isn't empty
                if isPassportHolderNewOrLaunched
                    && !model.highRiskAssessments.isEmpty
                    && validation.condition {
                    validationErrors[4].errors.append(validation.errorMessage.rawValue)
                }
            }
        }

        // Build the errors into a readable format, by section
        var message = ""

        for sectionError in validationErrors {
            let section = sectionError.section.rawValue
            let errors = sectionError.errors
            
            if !errors.isEmpty {
                // Add section header
                message += "📋 \(section)\n\n"
                
                // Add bullet points with emojis
                for error in errors {
                    let emoji = getEmoji(for: error)
                    message += "\(emoji) \(error)\n"
                }
                message += "\n\n"
            }
        }

        model.set(value: message.isEmpty, for: "formDidValidate")
        if (message.isEmpty) {
            model.set(status: .Draft)
        }
        
        return message
    }
    
    private func getEmoji(for error: String) -> String {
        if error.lowercased().contains("time") {
            return "⏰"
        } else {
            return "🔴"
        }
    }
    
    @objc func didTapCheckmarkButton(sender: UIBarButtonItem) {
        self.dismissKeyboard()

        if canSubmit() {
            self.navigationController?.popViewController(animated: true)
        } else {
            Alert.showValidation(title: "Inspection Incomplete", message: validationMessage())
        }
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

        // Handle watercraftHasDrainplugs changes
        if item.key == "watercraftHasDrainplugs" {
            let newValue = item.value.get(type: item.type) as? Bool ?? false
            if !newValue {
                // If watercraftHasDrainplugs is set to false, also set drainplugRemovedAtInspection to false
                model.set(value: false, for: "drainplugRemovedAtInspection")
                model.set(value: false, for: "drainplugRemovedAtInspectionInteracted")
                self.collectionView.reloadData()
            }
        }

        if highRiskFieldKeys.contains(item.key) {
            let value = item.value.get(type: item.type) as? Bool
            let alreadyHasHighRiskForm = !model.highRiskAssessments.isEmpty

            if model.cleanDrainDryAfterInspection == true && value == true {
                Alert.show(title: "Invalid Entry", message: "YES cannot be selected for both fields")

                model.set(value: false, for: item.key)
                item.value.set(value: false, type: item.type)
                NotificationCenter.default.post(name: .InputFieldShouldUpdate, object: item)
            } else if value == true && alreadyHasHighRiskForm {
                // set value
                model.set(value: true, for: item.key)
                self.showHighRiskForm(show: true)
                
                if item.key == "adultDreissenidFound" {
                    let highRisk = model.highRiskAssessments.first
                    highRisk?.set(value: true, for: "adultDreissenidMusselsFound")
                    item.value.set(value: true, type: item.type)
                    self.collectionView.reloadData()
                }
            } else if value == true {
                // Show a dialog for high risk form
                let highRiskModal: HighRiskModalView = HighRiskModalView.fromNib()
                highRiskModal.initialize(onSubmit: { [self] in
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
                let shouldShowHighRisk = shouldShowHighRiskForm()
                self.showHighRiskForm(show: shouldShowHighRisk)
                if !shouldShowHighRisk {
                    model.removeHighRiskAssessment()
                }
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
            
            let value = item.value.get(type: item.type) as? Bool

            if item.key == "highRisk-adultDreissenidMusselsFound" && value == true {
                model.set(value: true, for: "adultDreissenidFound")
                item.value.set(value: true, type: item.type)
                self.collectionView.reloadData()
            }
        } else if item.key.lowercased() == "countryprovince" {
            // Store directly
            InfoLog("countryProvider Selected: \(item)")
            
            model.set(value: item.value.get(type: item.type) as Any, for: item.key)
            // Now Get code
            guard let dropDown: DropdownInput = item as? DropdownInput else {
                return
            }
            guard let code: CountryProvince = dropDown.getCode() as? CountryProvince else {
                return
            }
            InfoLog("Selected Code: \(code)")
            model.set(value: code.country, for: "countryOfResidence")
            model.set(value: code.province, for: "provinceOfResidence")
        } else if item.key.lowercased().contains("cleandraindryafterinspection".lowercased()) {
            model.set(value: item.value.get(type: item.type) as Any, for: item.key)

            let value = item.value.get(type: item.type) as? Bool
            let alreadyHasHighRiskForm = !model.highRiskAssessments.isEmpty

            if model.highriskAIS == true && value == true {
                Alert.show(title: "Invalid Entry", message: "YES cannot be selected for both fields")
                model.set(value: false, for: item.key)
                self.collectionView.reloadData()
            } else if value == true && alreadyHasHighRiskForm {
                // set value
                model.set(value: true, for: item.key)
                self.showHighRiskForm(show: true)
            } else if value == true {
                // Show a dialog for high risk form
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
                let shouldShowHighRisk = shouldShowHighRiskForm()
                self.showHighRiskForm(show: shouldShowHighRisk)
                if !shouldShowHighRisk {
                    model.removeHighRiskAssessment()
                }
            }
        } else {
            // All other keys, store directly
            // TODO: needs cleanup for nil case
            
            // Special handling for the watercraft inspection fields that can interfere with each other
            if item.key == "previousInspection" {
                // When toggling previousInspection to true, we need special handling
                let newValue = item.value.get(type: item.type) as? Bool ?? false
                
                // First store the value normally
                model.set(value: newValue, for: item.key)
                
                // If we're turning it on and have AIS knowledge source set, make sure
                // days field doesn't get auto-populated with the wrong value
                if newValue == true {
                    // Clear the days field to prevent it from being populated with AIS source
                    model.set(value: "", for: "previousInspectionDays")
                    self.collectionView.reloadData()
                }
            } else if item.key == "previousInspectionDays" && model.previousInspection {
                // Only set the value if it's different from the AIS knowledge source
                let newValue = item.value.get(type: item.type) as? String ?? ""
                
                if newValue == model.previousAISKnowledeSource && !model.previousAISKnowledeSource.isEmpty {
                    // Don't allow days to be set to the AIS knowledge source
                    model.set(value: "", for: "previousInspectionDays")
                    self.collectionView.reloadData()
                } else {
                    // Otherwise set it normally
                    model.set(value: newValue, for: item.key)
                }
            } else {
                // For all other fields, just set the value normally
                model.set(value: item.value.get(type: item.type) as Any, for: item.key)
            }
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
        
        if item.key.lowercased() == "isNewPassportIssued".lowercased() {
            DispatchQueue.main.async {
                let isNewPassportIssued = item.value.get(type: item.type) as? Bool ?? nil
                self.showFullInspection = isNewPassportIssued == true && model.isPassportHolder
                self.collectionView.reloadData()
            }
        }
    }
    
    @objc func journeyItemValueChanged(notification: Notification) {
        guard let item: InputItem = notification.object as? InputItem, let model = self.model else {return}
        model.editJourney(inputItemKey: item.key, value: item.value.get(type: item.type) as Any)
    }
    
    
    func showPDFMap() {
        guard let path = Bundle.main.path(forResource: "pdfMap", ofType: "pdf") else {return}
        unowned let pdfView: PDFViewer = UIView.fromNib()
        let url = URL(fileURLWithPath: path)
        pdfView.initialize(name: "Map",file: url)
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
    
    func getPreviousMajorCityCell(indexPath: IndexPath) -> PreviousMajorCityCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "PreviousMajorCityCollectionViewCell", for: indexPath as IndexPath) as!
            PreviousMajorCityCollectionViewCell
    }
    
    func getDestinationMajorCityCell(indexPath: IndexPath) -> DestinationMajorCityCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "DestinationMajorCityCollectionViewCell", for: indexPath as IndexPath) as!
            DestinationMajorCityCollectionViewCell
    }
    
    func getBlankCell(indexPath: IndexPath) -> BlankCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "BlankCollectionViewCell", for: indexPath as IndexPath) as!
            BlankCollectionViewCell
    }
    
    private func arePreviousTogglesChecked(ref: WatercraftInspectionModel) -> Bool {
        if ref.commercialManufacturerAsPreviousWaterBody || ref.unknownPreviousWaterBody || ref.previousDryStorage {
            return true
        } else {
            return false
        }
    }
    
    private func areDestinationTogglesChecked(ref: WatercraftInspectionModel) -> Bool {
        if ref.commercialManufacturerAsDestinationWaterBody || ref.unknownDestinationWaterBody || ref.destinationDryStorage {
            return true
        } else {
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       guard let sectionType = WatercraftFromSection(rawValue: Int(section)), let model = self.model else {return 0}
       
       switch sectionType {
       case .JourneyDetails:
           let totalPreviousMajorCities = model.previousMajorCities.count
           let totalPreviousWaterBodies = model.previousWaterBodies.count
           let totalDestinationMajorCities = model.destinationMajorCities.count
           let totalDestinationWaterBodies = model.destinationWaterBodies.count
           return totalPreviousMajorCities + totalPreviousWaterBodies + totalDestinationMajorCities + totalDestinationWaterBodies + 6
       
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
            cell.setup(title: "Inspection Details", input: model.getInputputFields(for: sectionType, editable: isEditable), delegate: self, showDivider: false, showTopDivider: true, buttonName: "View Map", buttonIcon: "map", onButtonClick: { [weak self] in
                guard let strongSelf = self else {return}
                strongSelf.showPDFMap()
            })
            return cell
        case .HighRiskAssessmentFields:
            let cell = getBasicCell(indexPath: indexPath)
            cell.setup(title: "High Risk Assessment Fields", input: model.getInputputFields(for: sectionType, editable: isEditable), delegate: self, boxed: true, showDivider: false)
            return cell
        case .HighRiskAssessment:
            return getHighRiskAssessmentCell(indexPath: indexPath)
        case .GeneralComments:
            let cell = getBasicCell(indexPath: indexPath)
            cell.setup(title: "Comments", input: model.getInputputFields(for: sectionType, editable: isEditable), delegate: self, showDivider: false)
            return cell
        case .Divider:
            let dividerCell = getDividerCell(indexPath: indexPath)
            dividerCell.setup(visible: !showHighRiskAssessment)
            return dividerCell
        }
    }
    
    func getHighRiskAssessmentCell(indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = HighRiskFormSection(rawValue: Int(indexPath.row)), let model = self.model, let highRiskForm = model.highRiskAssessments.first else {
            return UICollectionViewCell()
        }
        
        let sectionTitle = "\(sectionType)".convertFromCamelCase()
        let cell = getBasicCell(indexPath: indexPath)
        cell.setup(title: sectionTitle, input: highRiskForm.getInputputFields(for: sectionType, editable: isEditable), delegate: self, showDivider: true)
        return cell
    }
    
    func getSizeForHighRiskAssessmentCell(indexPath: IndexPath) -> CGSize {
        guard let sectionType = HighRiskFormSection(rawValue: Int(indexPath.row)), let model = self.model, let highRiskForm = model.highRiskAssessments.first else {
            return CGSize()
        }
        
        let estimatedContentHeight = InputGroupView.estimateContentHeight(for: highRiskForm.getInputputFields(for: sectionType))
        return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight + BasicCollectionViewCell.minHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let sectionType = WatercraftFromSection(rawValue: Int(indexPath.section)), let model = self.model else {
            return CGSize(width: 0, height: 0)
        }
        switch sectionType {
        case .PassportInfo:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: model.getInputputFields(for: sectionType))
            return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight + BasicCollectionViewCell.minHeight)
        case .BasicInformation:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: model.getInputputFields(for: sectionType))
            return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight + BasicCollectionViewCell.minHeight)
        case .WatercraftDetails:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: model.getInputputFields(for: sectionType))
            return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight + BasicCollectionViewCell.minHeight)
        case .JourneyDetails:
            return estimateJourneyDetailsCellHeight(for: indexPath)
        case .InspectionDetails:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: model.getInputputFields(for: sectionType))
            return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight + BasicCollectionViewCell.minHeight)
        case .HighRiskAssessmentFields:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: model.getInputputFields(for: sectionType))
            return CGSize(width: self.collectionView.bounds.width - 16, height: estimatedContentHeight + BasicCollectionViewCell.minHeight)
        case .HighRiskAssessment:
            return getSizeForHighRiskAssessmentCell(indexPath: indexPath)
        case .GeneralComments:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: model.getInputputFields(for: sectionType))
            return CGSize(width: self.collectionView.frame.width, height: estimatedContentHeight + 80)
        case .Divider:
            return CGSize(width: self.collectionView.frame.width, height: 30)
        }
    }
    
    @objc private func addPreviousWaterBody(sender: Any?) {
        /// -- Model
        guard let model = self.model else { return }
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
        }
    }
    
    @objc private func addPreviousMajorCity(sender: Any?) {
        /// -- Model
        guard let model = self.model else { return }
        /// ---------nahir city picker------------
        self.setNavigationBar(hidden: true, style: .black)
        let majorCityPicker: MajorCityPicker = UIView.fromNib()
        self.viewLayoutMarginsDidChange()
        majorCityPicker.setup() { (result) in
            print(result)
            for majorCity in result {
                model.setMajorCity(isPrevious: true, majorCity: majorCity)
            }
            self.setNavigationBar(hidden: false, style: .black)
            self.viewLayoutMarginsDidChange()
            self.collectionView.reloadData()
        }
    }
    
    @objc private func addDestinationMajorCity(sender: Any?) {
        /// -- Model
        guard let model = self.model else { return }
        /// ---------major city picker------------
        self.setNavigationBar(hidden: true, style: .black)
        let majorCityPicker: MajorCityPicker = UIView.fromNib()
        self.viewLayoutMarginsDidChange()
        majorCityPicker.setup() { [weak self] (result) in
            guard let strongerSelf = self else {return}
            print(result)
            for majorCity in result {
                model.setMajorCity(isPrevious: false, majorCity: majorCity)
            }
            strongerSelf.setNavigationBar(hidden: false, style: .black)
            strongerSelf.viewLayoutMarginsDidChange()
            strongerSelf.collectionView.reloadData()
        }
        /// --------------------------------
    }
    
    @objc private func addNextWaterBody(sender: Any?) {
        /// -- Model
        guard let model = self.model else { return }
        /// ---------waterbody picker------------
        self.setNavigationBar(hidden: true, style: .black)
        let waterBodyPicker: WaterbodyPicker = UIView.fromNib()
        self.viewLayoutMarginsDidChange()
        waterBodyPicker.setup() { [weak self] (result) in
            guard let strongerSelf = self else {return}
            print(result)
            for waterBody in result {
                model.addDestinationWaterBody(model: waterBody)
            }
            strongerSelf.setNavigationBar(hidden: false, style: .black)
            strongerSelf.viewLayoutMarginsDidChange()
            strongerSelf.collectionView.reloadData()
        }
        /// --------------------------------
    }
    
    // Reload Journey Details section
    private func reloadJourneyDetailSection(indexPath: IndexPath) {
        self.collectionView.performBatchUpdates({
            self.collectionView?.reloadSections(IndexSet(integer: indexPath.section))
        }, completion: nil)

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
            let itemsIndex: Int = indexPath.row - 2
            let previousWaterBody = model.previousWaterBodies[itemsIndex]
            cell.setup(with: previousWaterBody, isEditable: self.isEditable, input: model.getPreviousWaterBodyInputFields(for: .JourneyDetails, editable: isEditable, index: itemsIndex),  delegate: self, onDelete: { [weak self] in
                guard let strongSelf = self else {return}
                model.removePreviousWaterBody(at: itemsIndex)
                strongSelf.collectionView.performBatchUpdates({
                    strongSelf.collectionView.reloadSections(IndexSet(integer: indexPath.section))
                }, completion: nil)
            })
            return cell
        case .DestinationWaterBody:
          let cell = getDestinationWaterBodyCell(indexPath: indexPath)
          var itemsIndex: Int = 0
          itemsIndex = indexPath.row - (model.previousMajorCities.count + model.previousWaterBodies.count + 4)
          if itemsIndex >= 0 && itemsIndex < model.destinationWaterBodies.count {
              let destinationWaterBody = model.destinationWaterBodies[itemsIndex]
              cell.setup(with: destinationWaterBody, isEditable: self.isEditable, delegate: self, onDelete: { [weak self] in
                  guard let strongSelf = self else {return}
                  model.removeDestinationWaterBody(at: itemsIndex)
                  strongSelf.collectionView.performBatchUpdates({
                      strongSelf.collectionView.reloadSections(IndexSet(integer: indexPath.section))
                  }, completion: nil)
              })
          }
          return cell

        
        case .PreviousMajorCity:
            let cell = getPreviousMajorCityCell(indexPath: indexPath)
            let itemsIndex: Int = 0
            let previousMajorCity = model.previousMajorCities[itemsIndex]
            cell.setup(with: previousMajorCity, isEditable: self.isEditable, input: model.getPreviousMajorCityInputFields(for: .JourneyDetails, editable: isEditable, index: itemsIndex), delegate: self, onDelete: { [weak self] in
                guard let strongSelf = self else {return}
                model.deleteMajorCity(isPrevious: true)
                strongSelf.collectionView.performBatchUpdates({
                    strongSelf.collectionView.reloadSections(IndexSet(integer: indexPath.section))
                }, completion: nil)
            })
            
            return cell
        
        case .DestinationMajorCity:
            let cell = getDestinationMajorCityCell(indexPath: indexPath)
            let itemsIndex: Int = 0
            let destinationMajorCity = model.destinationMajorCities[itemsIndex]
            cell.setup(with: destinationMajorCity, isEditable: self.isEditable, delegate: self, onDelete: { [weak self] in
                guard let strongSelf = self else {return}
                model.deleteMajorCity(isPrevious: false)
                strongSelf.collectionView.performBatchUpdates({
                    strongSelf.collectionView.reloadSections(IndexSet(integer: indexPath.section))
                }, completion: nil)
            })
            
            return cell
        case .AddPreviousWaterBody:
            let hasNonEmptyOtherWaterbody = model.previousWaterBodies.contains { !$0.otherWaterbody.isEmpty } 
            let cell = getButtonCell(indexPath: indexPath)
            cell.setup(
                with: "Add Previous Water Body",
                isEnabled: isEditable,
                config: FormButtonCollectionViewCell.Config(
                    status: self.model?.previousDryStorage ?? false,
                    unknownWaterBodyStatus: self.model?.unknownPreviousWaterBody ?? false,
                    commercialManufacturerStatus: self.model?.commercialManufacturerAsPreviousWaterBody ?? false,
                    isPreviousJourney: true,
                    displaySwitch: true,
                    displayUnknowSwitch: true,
                    otherWaterbodyPrev: hasNonEmptyOtherWaterbody)
            ) { [weak self] action in
                guard let strongSelf = self else {return}
                /// ----- Switch Action ------
                switch action {
                case .statusChange(let result):
                    InfoLog("User change status: \(result) of previous water body")
                    strongSelf.model?.setJournyStatusFlags(dryStorage: result.dryStorage, unknown: result.unknown, commercialManufacturer: result.commercialManufacturer, isPrevious: true)
                    strongSelf.reloadJourneyDetailSection(indexPath: indexPath)
                case .add:
                    /// ---------waterbody picker------------
                    InfoLog("User want to add previous water body")
                    strongSelf.setNavigationBar(hidden: true, style: .black)
                    let waterBodyPicker: WaterbodyPicker = UIView.fromNib()
                    strongSelf.viewLayoutMarginsDidChange()
                    waterBodyPicker.setup() { [weak self] (result) in
                        guard let strongerSelf = self else {return}
                        for waterBody in result {
                            model.addPreviousWaterBody(model: waterBody)
                        }
                        strongerSelf.setNavigationBar(hidden: false, style: .black)
                        strongerSelf.viewLayoutMarginsDidChange()
                        strongerSelf.collectionView.reloadData()
                        waterBodyPicker.removeFromSuperview()
                    }
                case .addMajorCity:
                    /// ---------major city picker------------
                    InfoLog("User want to add previous major city")
                    strongSelf.setNavigationBar(hidden: true, style: .black)
                    let majorCityPicker: MajorCityPicker = UIView.fromNib()
                    strongSelf.viewLayoutMarginsDidChange()
                    majorCityPicker.setup() { [weak self] (result) in
                        guard let strongerSelf = self else {return}
                        for majorCity in result {
                            model.setMajorCity(isPrevious: true, majorCity: majorCity)
                        }
                        strongerSelf.setNavigationBar(hidden: false, style: .black)
                        strongerSelf.viewLayoutMarginsDidChange()
                        strongerSelf.collectionView.reloadData()
                        majorCityPicker.removeFromSuperview()
                    }
                    
                    /// --------------------------------
                }
            }
            return cell
        case .AddDestinationWaterBody:
            let hasNonEmptyOtherWaterbody = model.destinationWaterBodies.contains { !$0.otherWaterbody.isEmpty }
            let cell = getButtonCell(indexPath: indexPath)
            cell.setup(
                with: "Add Destination Water Body",
                isEnabled: isEditable,
                config: FormButtonCollectionViewCell.Config(
                    status: self.model?.destinationDryStorage ?? false,
                    unknownWaterBodyStatus: self.model?.unknownDestinationWaterBody ?? false,
                    commercialManufacturerStatus: self.model?.commercialManufacturerAsDestinationWaterBody ?? false,
                    isPreviousJourney: false,
                    displaySwitch: true,
                    displayUnknowSwitch: true,
                    otherWaterbodyDest: hasNonEmptyOtherWaterbody)
            ) { [weak self] action in
                
                guard let strongSelf = self else {return}
                /// ----- Switch Action ------
                switch action {
                case .statusChange(let result):
                    InfoLog("User change status: \(result) of destination water body")
                    strongSelf.model?.setJournyStatusFlags(dryStorage: result.dryStorage, unknown: result.unknown, commercialManufacturer: result.commercialManufacturer, isPrevious: false)
                    strongSelf.reloadJourneyDetailSection(indexPath: indexPath)
                case .add:
                    /// ---------waterbody picker------------
                    strongSelf.setNavigationBar(hidden: true, style: .black)
                    let waterBodyPicker: WaterbodyPicker = UIView.fromNib()
                    strongSelf.viewLayoutMarginsDidChange()
                    waterBodyPicker.setup() { [weak self] (result) in
                        guard let strongerSelf = self else {return}
                        print(result)
                        for waterBody in result {
                            model.addDestinationWaterBody(model: waterBody)
                        }
                        strongerSelf.setNavigationBar(hidden: false, style: .black)
                        strongerSelf.viewLayoutMarginsDidChange()
                        strongerSelf.collectionView.reloadData()
                    }
                case .addMajorCity:
                    /// ---------waterbody picker------------
                    InfoLog("User want to add destination major city")
                    strongSelf.setNavigationBar(hidden: true, style: .black)
                    let majorCityPicker: MajorCityPicker = UIView.fromNib()
                    strongSelf.viewLayoutMarginsDidChange()
                    majorCityPicker.setup() { [weak self] (result) in
                        guard let strongerSelf = self else {return}
                        for majorCity in result {
                            model.setMajorCity(isPrevious: false, majorCity: majorCity)
                        }
                        strongerSelf.setNavigationBar(hidden: false, style: .black)
                        strongerSelf.viewLayoutMarginsDidChange()
                        strongerSelf.collectionView.reloadData()
                        majorCityPicker.removeFromSuperview()
                    }
                    /// --------------------------------
                }
            }
            return cell
        case .Divider:
            let dividerCell = getDividerCell(indexPath: indexPath)
            dividerCell.setup(visible: true)
            return dividerCell
        case .PreviousHeader:
            let cell = getHeaderCell(indexPath: indexPath)
            cell.setup(with: "Previous Waterbody *")
            return cell
        case .DestinationHeader:
            let cell = getHeaderCell(indexPath: indexPath)
            cell.setup(with: "Destination Waterbody *")
            return cell
        case .Blank:
            let blankCell = getBlankCell(indexPath: indexPath)
            blankCell.setup(visible: true)
            return blankCell
        }
    }
    
    private func estimateJourneyDetailsCellHeight(for indexPath: IndexPath) -> CGSize {
        let width = self.collectionView.frame.width
        switch getJourneyDetailsCellType(for: indexPath) {
        case .Header:
            return CGSize(width: width, height: 50)
        case .PreviousMajorCity:
            return CGSize(width: width, height: 200)
        case .DestinationMajorCity:
            return CGSize(width: width, height: 200)
        case .PreviousWaterBody:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: WatercraftInspectionFormHelper.getPreviousWaterBodyFields(index: 0))
            return CGSize(width: width, height: estimatedContentHeight + 20)
        case .DestinationWaterBody:
            let estimatedContentHeight = InputGroupView.estimateContentHeight(for: WatercraftInspectionFormHelper.watercraftInspectionDestinationWaterBodyInputs(index: 0))
            return CGSize(width: width, height: estimatedContentHeight + 20)
        case .AddPreviousWaterBody:
            return CGSize(width: width, height: 110)
        case .AddDestinationWaterBody:
            return CGSize(width: width, height: 110)
        case .Divider:
            return CGSize(width: width, height: 10)
        case .PreviousHeader:
            return CGSize(width: width, height: 50)
        case .DestinationHeader:
            return CGSize(width: width, height: 50)
        case .Blank:
            return CGSize(width: width, height: 1)
        }
    }
    
    
    /// Determines the type of cell for a given index path in the journey details section.
    ///
    /// This function calculates the type of cell to display in the journey details section based on the index path.
    /// It takes into account the counts of  previous water bodies, previous major cities, destination water bodies,
    /// and destination major cities.
    ///
    /// - Parameter indexPath: The index path for which the cell type needs to be determined.
    /// - Returns: The type of cell for the given index path.
    private func getJourneyDetailsCellType(for indexPath: IndexPath) -> JourneyDetailsSectionRow {
        guard let model = self.model else {return .Divider}
        
        // If the prev commercial/unknown/stored are toggled OFF, we delete the cities from model
        if !arePreviousTogglesChecked(ref: model) && model.previousWaterBodies.isEmpty {
            model.deleteMajorCity(isPrevious: true)
        }
        
        // If the prev commercial/unknown/stored are toggled ON, we delete the waterbodies from model
        if arePreviousTogglesChecked(ref: model) && !model.previousWaterBodies.isEmpty {
            for index in stride(from: model.previousWaterBodies.count -  1, through:  0, by: -1) {
                model.removePreviousWaterBody(at: index)
            }
        }
        
        // If the dest commercial/unknown/stored are toggled OFF, we delete the cities from model
        if !areDestinationTogglesChecked(ref: model) && model.destinationWaterBodies.isEmpty {
            model.deleteMajorCity(isPrevious: false)
        }
        
        // If the dest commercial/unknown/stored are toggled ON, we delete the waterbodies from model
        if areDestinationTogglesChecked(ref: model) && !model.destinationWaterBodies.isEmpty {
            for index in stride(from: model.destinationWaterBodies.count -  1, through:  0, by: -1) {
                model.removeDestinationWaterBody(at: index)
            }
        }
        
        // Header for "Journey Details" always at top
        if indexPath.row == 0 {
            return .Header
        }
        
        // Previous Waterbody comes second
        if indexPath.row == 1 {
            return .PreviousHeader
        }
        
        /// If we had 0 previous waterbodies we would skip this
        /// Row = 2
        /// previousWaterBody.count == 0
        /// 2 <= min(2 - 2, 0 - 1) + 2 --> false, skip
        ///
        /// Comparatively, if we have 1 previousWaterBody we would show this cell for the row
        /// Row = 2
        /// previousWaterBody.count = 1
        /// 2 <= min(2 - 2, 1 - 1) + 2 --> true,  show the previous waterbody
        // Essentially, we hit this if the indexPath.row == 2 AND there is at least
        // 1 previousWaterBody to show. It will continue to post all waterbodies here as well
        let previousWaterBodyCount = min(indexPath.row - 2, model.previousWaterBodies.count - 1)
        if indexPath.row <= previousWaterBodyCount + 2 {
            return .PreviousWaterBody
        }
        
        /// No previousWaterBodies, we should get to this part on Row = 2
        /// Row = 2
        /// previousWaterBody.count = 0
        /// 2 == min(3 - 2, 0 - 1) + 3  --> true, show the Add Previous Water Button
        ///
        /// Comparatively, if we had 1 previousWaterBody, we reach this button on Row = 3
        /// Row = 3
        /// previousWaterBody.count = 1
        /// 3 == min(2 - 2, 1 - 1) + 3 --> true, show the Add Previous Water Button
        // This shows the Add Previous Waterbody (and Previous Major Cities button) after we've listed all
        // the previous waterbodies above.
        if indexPath.row == previousWaterBodyCount + 3 {
            return .AddPreviousWaterBody
        }
        
        // This will show the Previous Major City, and it will be below the Previous Add buttons
        let previousMajorCityCount = min(indexPath.row - previousWaterBodyCount - 4, model.previousMajorCities.count - 1)
        if indexPath.row <= previousWaterBodyCount + previousMajorCityCount + 4 {
            return .PreviousMajorCity
        }
        
        // Destination header always comes after Previous Major City
        if indexPath.row == previousWaterBodyCount + previousMajorCityCount + 5 {
            return .DestinationHeader
        }
        
        // Similar to above, we perpetually list any destination waterbodies above the Previous Add buttons
        let destinationWaterBodyCount = min(indexPath.row - previousWaterBodyCount - previousMajorCityCount - 6, model.destinationWaterBodies.count - 1)
        if indexPath.row <= previousWaterBodyCount + previousMajorCityCount + destinationWaterBodyCount + 6 {
            return .DestinationWaterBody
        }
        
        // Eventually, we will list our Destination Add buttons once all Destination Waterbodies are listed
        if indexPath.row == previousWaterBodyCount + previousMajorCityCount + destinationWaterBodyCount + 7 {
            return .AddDestinationWaterBody
        }
        
        // We show our Destination Major City beneath the Destination Add Buttons
        let destinationMajorCityCount = min(indexPath.row - previousWaterBodyCount - previousMajorCityCount - destinationWaterBodyCount - 8, model.destinationMajorCities.count - 1)
        
        if indexPath.row <= previousWaterBodyCount + previousMajorCityCount + destinationWaterBodyCount + destinationMajorCityCount + 8 {
            return .DestinationMajorCity
        }
        
        // Finally, once everything is exhausted, we show the blank spot unless we skipped it earlier
        // a divider is provided as topDivider for the Inspection Details
        return .Blank
    }
}
