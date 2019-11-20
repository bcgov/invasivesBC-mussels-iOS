//
//  TableVIew.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-19.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class TableView: UIView {
    
    // MARK: Outlets
    @IBOutlet weak var headerContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Constants
    private let tableCells = [
        "TableRowTableViewCell",
    ]
    
    // MARK: Variables
    private var model: TableViewModel? = nil
    private weak var stackView: UIStackView?
    private var tableHeaders: [String: UIView] = [String: UIView]()
    
    
    // MARK: Setup
    public func initialize(with model: TableViewModel, in container: UIView) {
        container.addSubview(self)
        self.addConstraints(for: container)
        self.model = model
        container.layoutIfNeeded()
        addHeaders() // Add headers also set up table
        self.backgroundColor = Colors.primary
    }
    
    private func addConstraints(for view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        self.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        self.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    // MARK: Headers
    private func addHeaders() {
        guard let model = self.model else {return}
        
        // Create StackView
        let stackView   = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.horizontal
        stackView.distribution  = UIStackView.Distribution.fillProportionally
        stackView.alignment = UIStackView.Alignment.leading
        stackView.spacing   = 16.0
       
        // Add Labels
        tableHeaders = [String: UIView]()
        var last = model.headers.last
        for header in model.headers {
            let label = UILabel()
            label.text = model.displayedHeaders.contains(header) ? header : " "
            label.font = Table.headerFont
            label.textAlignment = .left
            label.heightAnchor.constraint(equalToConstant: Table.headerLabelHeight).isActive = true
            
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: model.columnSizes[header] ?? 5).isActive = true
            
            stackView.addArrangedSubview(label)
            
            // Store reference to header (so cell content can be constrained to it)
            tableHeaders[header] = label
        }
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Assign local variable
        self.stackView = stackView
        // Add Subview
        self.headerContainerView.addSubview(stackView)
        
        // Add Constraints
        stackView.leadingAnchor.constraint(equalTo: self.headerContainerView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.headerContainerView.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: self.headerContainerView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.headerContainerView.bottomAnchor).isActive = true
        
        // Setup table
        self.setUpTable()
        
    }
}

extension TableView: UITableViewDelegate, UITableViewDataSource {
    private func setUpTable() {
        if self.tableView == nil {return}
        tableView.delegate = self
        tableView.dataSource = self
        //        tableView.remembersLastFocusedIndexPath = true
        for cell in tableCells {
            register(cell: cell)
        }
    }
    
    func register(cell name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }
    
    func getRowCell(indexPath: IndexPath) -> TableRowTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "TableRowTableViewCell", for: indexPath) as! TableRowTableViewCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let model = self.model else  {
            return 0
        }
        return model.rows.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = self.model else {
            return UITableViewCell()
        }
        let cell = getRowCell(indexPath: indexPath)
        cell.setup(model: model.rows[indexPath.row], tableHeaders: tableHeaders)
        return cell
    }
    
    
}
