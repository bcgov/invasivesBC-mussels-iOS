import Foundation
import UIKit

extension UISearchBar
{
    func setPlaceholderTextColor(color: UIColor)
    {
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = color
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = color
    }
    
    func setMagnifyingGlassColor(color: UIColor)
    {
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = color
    }
}

private enum contraintType {
    case top
    case bottom
    case centerX
    case centerY
    case leading
    case trailing
    case height
}

class MajorCityPicker: UIView, Theme {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var barContainer: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectionsHeightConstraint: NSLayoutConstraint!
    
    // MARK: Constants
    private let tableCells = [
        "MajorCityTableViewCell",
    ]
    
    private let collectionCells = [
        "SelectedMajorCityCollectionViewCell",
    ]
    
    // MARK: Variables:
    private var items: [DropdownModel] = []
    private var filteredItems: [DropdownModel] = []
    private var completion: ((_ result: [MajorCitiesTableModel]) -> Void )?
    private var selection: DropdownModel = DropdownModel(display: "", key: "0")
    private var viewConstraints: [contraintType : NSLayoutConstraint] = [contraintType : NSLayoutConstraint]()
    
    deinit {
        print("de-init majorCityPicker")
    }
    
    @IBAction func selectAction(_ sender: UIButton) {
        returnResult()
        dismissWithAnimation()
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        guard let callback = self.completion else {return}
        callback([])
        dismissWithAnimation()
    }
    
    private func dismissWithAnimation() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
            self.layoutIfNeeded()
        }) { (done) in
            self.removeFromSuperview()
        }
    }
    
    /**
     Displays Major City picker in Container and returns DropdownModel Result
     */
    func setup(result: @escaping([MajorCitiesTableModel]) -> Void) {
        self.completion = result
        self.loadMajorCities()
        self.position()
        self.style()
        self.setUpTable()
        self.setupCollectionView()
        self.searchBar.delegate = self
        self.tableView.reloadData()
        self.selectionsHeightConstraint.constant = 0
        self.selectButton.isEnabled = !(self.selection.display == "")
        searchBar.isAccessibilityElement = true
        searchBar.accessibilityLabel = "search-majorcities"
        searchBar.accessibilityValue = "search-majorcities"
        searchBar.searchTextField.accessibilityValue = "type-search-majorcities"
        searchBar.searchTextField.accessibilityLabel = "type-search-majorcities"
        collectionView.accessibilityLabel = "selected-majorcities"
        collectionView.accessibilityValue = "selected-majorcities"
        tableView.accessibilityValue = "majorcities-table"
        tableView.accessibilityLabel = "majorcities-table"
        barContainer.accessibilityValue = "majorcitypicker-nav"
        barContainer.accessibilityLabel = "majorcitypicker-nav"
    }
    
    // Return Results
    private func returnResult() {
        guard let callback = self.completion else {return}
        var results: [MajorCitiesTableModel] = []
        if let id = Int(self.selection.key), let model = Storage.shared.getMajorCityModel(withId: id) {
            results.append(model)
        }
        return callback(results)
    }
    
    private func selected(item: DropdownModel) {
        if indexOf(selection: item) != nil {
            remove(item: item)
        } else {
            remove(item: self.selection)
            add(item: item)
        }
    }
    
    private func add(item: DropdownModel) {
        if indexOf(selection: item) != nil {return}
        self.selection = item;
        self.showOrHideSelectionsIfNeeded()
        self.collectionView.reloadData()
    }
    
    private func remove(item: DropdownModel) {
        self.selection = DropdownModel(display: "", key: "0")
        self.showOrHideSelectionsIfNeeded()
        self.collectionView.reloadData()
        self.tableView.reloadData()
    }
    
    private func showOrHideSelectionsIfNeeded() {
        let selectTitle = !(self.selection.display == "") ? "Select (1)" : "Select"
        self.selectButton.setTitle(selectTitle, for: .normal)
        self.selectButton.isEnabled = !(self.selection.display == "")
        UIView.animate(withDuration: 0.3) {
            self.selectionsHeightConstraint.constant = !(self.selection.display == "") ? 60 : 0
            self.collectionView.alpha = !(self.selection.display == "") ? 1 : 0
            self.layoutIfNeeded()
        }
    }
    
    private func indexOf(selection: DropdownModel) -> Int? {
        if selection.display == self.selection.display && selection.key == self.selection.key {
            return 0
        }
        
        return nil
    }
    
    // Load all major cities from storage
    private func loadMajorCities() {
        self.items = Storage.shared.getMajorCitiesDropdowns()
        self.filteredItems = items
        self.tableView.alpha = 1
    }
    
    // Reset results to show all major cities
    private func resetSearch() {
        self.filteredItems = self.items
        UIView.animate(withDuration: 0.3) {
            self.tableView.alpha = 1
            self.layoutIfNeeded()
        }
        self.tableView.reloadData()
    }
    
    // Filter Reaults
    private func filter(by text: String) {
        self.filteredItems = items.filter{$0.display.lowercased().contains(text.lowercased())}.sorted(by: { (first, second) -> Bool in
            return first.display.lowercased() < second.display.lowercased()
        })
        self.tableView.reloadData()
    }
    
    private func position() {
        guard let window = UIApplication.shared.connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first else {return}
        // Set initial position with 0 alpha and add as subview
        self.frame = CGRect(x: 0, y: window.frame.maxY, width: window.bounds.width, height: window.bounds.height)
        self.center.x = window.center.x
        self.alpha = 0
        window.addSubview(self)
        window.layoutIfNeeded()
        // Animate setting alpha to 1 and adding constraints to equal container's
        createConstraints()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        viewConstraints[.leading]?.isActive = true
        viewConstraints[.trailing]?.isActive = true
        viewConstraints[.height]?.isActive = true
        viewConstraints[.centerY]?.constant = window.frame.height
        viewConstraints[.centerY]?.isActive = true
        window.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: CGFloat(0.5), options: .curveEaseInOut, animations: {
            self.alpha = 1
            // 28 is so that it covers the status bar as well
            self.viewConstraints[.centerY]?.constant = -20
            window.layoutIfNeeded()
        }) { (done) in
            UIView.animate(withDuration: 0.1) {
                self.viewConstraints[.centerY]?.isActive = false
                self.viewConstraints[.height]?.isActive = false
                self.viewConstraints[.bottom]?.isActive = true
                self.viewConstraints[.top]?.isActive = true
                window.layoutIfNeeded()
            }
        }
    }
    
    private func createConstraints() {
        guard let window = UIApplication.shared.connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first else {return}
        viewConstraints[.trailing] = self.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: 0)
        viewConstraints[.leading] = self.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 0)
        viewConstraints[.centerY] = self.centerYAnchor.constraint(equalTo: window.centerYAnchor, constant: 0)
        viewConstraints[.centerX] = self.centerXAnchor.constraint(equalTo: window.centerXAnchor, constant: 0)
        viewConstraints[.height] = self.heightAnchor.constraint(equalTo: window.heightAnchor, constant: 0)
        viewConstraints[.top] = self.topAnchor.constraint(equalTo: window.topAnchor, constant: -20)
        viewConstraints[.bottom] = self.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: 0)
    }
    
    private func style() {
        self.barContainer.backgroundColor = Colors.primary
        self.backButton.setTitleColor(.white, for: .normal)
        self.selectButton.setTitleColor(.white, for: .normal)
        self.searchBar.barTintColor = Colors.primary
        self.titleLabel.textColor = UIColor.white
        searchBar.setPlaceholderTextColor(color: .white)
        searchBar.setMagnifyingGlassColor(color: .white)
        let attributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)
        ]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)
        
    }
}

// MARK: Search Bar Delegate
extension MajorCityPicker: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.resetSearch()
            return
        }
        
        self.filter(by: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {}
}

// MARK: TableView
extension MajorCityPicker: UITableViewDataSource, UITableViewDelegate {
    private func setUpTable() {
        if self.tableView == nil {return}
        tableView.delegate = self
        tableView.dataSource = self
        for cell in tableCells {
            register(table: cell)
        }
    }
    
    func register(table cellName: String) {
        let nib = UINib(nibName: cellName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellName)
    }
    
    func getRowCell(indexPath: IndexPath) -> MajorCityTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "MajorCityTableViewCell", for: indexPath) as! MajorCityTableViewCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = getRowCell(indexPath: indexPath)
        cell.setup(item: filteredItems[indexPath.row], optionSelected: self.indexOf(selection: filteredItems[indexPath.row]) != nil, onClick: {
            self.selected(item: self.filteredItems[indexPath.row])
        })
        
        return cell
    }
}

// MARK: CollectionView
extension MajorCityPicker: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private func setupCollectionView() {
        guard let collectionView = self.collectionView else {return}
        for cell in collectionCells {
            register(collection: cell)
        }
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func register(collection cellName: String) {
        guard let collectionView = self.collectionView else {return}
        let nib = UINib(nibName: cellName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: cellName)
    }
    
    func getSelectedCell(indexPath: IndexPath) -> SelectedMajorCityCollectionViewCell {
        return collectionView!.dequeueReusableCell(withReuseIdentifier: "SelectedMajorCityCollectionViewCell", for: indexPath as IndexPath) as! SelectedMajorCityCollectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = getSelectedCell(indexPath: indexPath)
        cell.setup(item: self.selection) {
            self.remove(item: self.selection)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = self.selection
        let textWidth = item.display.width(withConstrainedHeight: self.collectionView.bounds.height, font: Fonts.getPrimary(size: 17))
        let buttonWidth: CGFloat = 35
        let padding: CGFloat = 32
        return CGSize(width: textWidth + buttonWidth + padding, height: 60)
    }
    
}
