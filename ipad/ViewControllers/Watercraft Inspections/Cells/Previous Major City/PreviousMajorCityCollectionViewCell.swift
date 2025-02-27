import UIKit

class PreviousMajorCityCollectionViewCell: BaseJourneyCollectionViewCell, Theme {
    
    // Todo update this
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cellContainer: UIView!
    @IBOutlet weak var fieldHeader: UILabel!
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var dropdownContainer: UIView!

    var onDelete: (()-> Void)?
    weak var delegate: InputDelegate?
    var model: MajorCityModel?
    var isEditable: Bool = false
    weak var input: UIView?

    @IBAction func optionsAction(_ sender: UIButton) {
        guard let onDelete = onDelete else {return}
        return onDelete()
    }
    
    func setup(with model: MajorCityModel, isEditable: Bool, input items: [InputItem], delegate: InputDelegate, onDelete: @escaping ()-> Void) {
        self.isEditable = isEditable
        self.onDelete = onDelete
        self.delegate = delegate
        self.model = model
        
        // Style the cell first to ensure proper layout
        style()
        
        // Set the text field with the major city info
        let cityText = "\(model.majorCity), \(model.province), \(model.country)"
        self.inputField.text = cityText
        fieldHeader.text = "Closest Major City to Previous Waterbody"
        
        // Guard against nil dropdownContainer
        guard let container = dropdownContainer else {
            print("Error: dropdownContainer is nil. Check IBOutlet connection.")
            return
        }
        
        // Get the index from the first input item's key
        let index = items.first?.key.components(separatedBy: "-").last ?? "0"
        
        // Check if commercial manufacturer is set by looking at the parent delegate
        if let parentVC = delegate as? WatercraftInspectionViewController,
           let parentModel = parentVC.model,
           parentModel.commercialManufacturerAsPreviousWaterBody {
            // Hide the dropdown container if commercial manufacturer is set
            container.isHidden = true
            return
        }
        
        // Create a dropdown input for number of days out
        let daysOutKey = "previousWaterBody-numberOfDaysOut-\(index)"
        let daysOutDropdown = DropdownInput(
            key: daysOutKey,
            header: "Number of days out of waterbody?",
            editable: isEditable,
            value: model.numberOfDaysOut.isEmpty ? "N/A" : model.numberOfDaysOut,
            width: .Full,
            dropdownItems: DropdownHelper.shared.getDropdown(for: .daysOutOfWater)
        )
        
        // Setup input group
        let inputGroup = InputGroupView()
        self.input = inputGroup
        
        // Add observer for value changes
        NotificationCenter.default.removeObserver(self, name: .InputItemValueChanged, object: daysOutDropdown)
        NotificationCenter.default.addObserver(self, 
            selector: #selector(journeyItemValueChanged), 
            name: .InputItemValueChanged, 
            object: daysOutDropdown)
        
        // Configure container
        container.backgroundColor = .clear
        container.clipsToBounds = false
        container.isHidden = false
        
        // Initialize input group with the dropdown
        inputGroup.initialize(with: [daysOutDropdown], delegate: delegate, in: container)
        
        // Show/hide delete button based on editability
        self.deleteButton.alpha = isEditable ? 1 : 0
        self.deleteButton.isEnabled = isEditable
        
        // Force layout update
        self.layoutIfNeeded()
    }
    
    @objc func journeyItemValueChanged(notification: Notification) {
        guard let item = notification.object as? InputItem,
              let value = item.value.get(type: item.type) as? String else { return }
        
        // Update both the journey model and major city model
        model?.setNumberOfDaysOut(value)
        
        // Post notification for journey item change
        NotificationCenter.default.post(name: .journeyItemValueChanged, object: item)
    }
    
    private func style() {
        deleteButton.tintColor = Colors.primary
        styleInput(field: inputField, header: fieldHeader, editable: false)
        inputField.isEnabled = false
        contentView.backgroundColor = UIColor.yellow
        contentView.layer.cornerRadius = 3
        contentView.backgroundColor = UIColor.white
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor(red:0.8, green:0.81, blue:0.82, alpha:1).cgColor
    }
}

