import UIKit

class PreviousMajorCityCollectionViewCell: BaseJourneyCollectionViewCell, Theme {
    
    // Todo update this
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cellContainer: UIView!
    @IBOutlet weak var fieldHeader: UILabel!
    @IBOutlet weak var inputField: UITextField!
    
    var onDelete: (()-> Void)?
    weak var delegate: InputDelegate?
    var model: MajorCityModel?
    var isEditable: Bool = false

    @IBAction func optionsAction(_ sender: UIButton) {
        guard let onDelete = onDelete else {return}
        return onDelete()
    }
    
    func setup(with model: MajorCityModel, isEditable: Bool, delegate: InputDelegate, onDelete: @escaping ()-> Void) {
        self.isEditable = isEditable
        self.onDelete = onDelete
        self.delegate = delegate
        self.inputField.text = model.majorCity + ", " + model.province + ", " + model.country
        style()
        self.deleteButton.alpha = isEditable ? 1 : 0
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

