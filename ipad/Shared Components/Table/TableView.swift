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
    
    weak var container: UIView?
    private var emptyStateMessage = "You have not created entries"
    private var emptyStateTitle = "Loooking a little empty around here"
    private var emptyStateIconName = "folder.fill.badge.plus"
    
    // MARK: Constants
    private let tableCells = [
        "TableRowTableViewCell",
        "TableEmptyStateTableViewCell"
    ]
    
    // MARK: Variables
    private var model: TableViewModel? = nil
    private weak var stackView: UIStackView?
    private var tableHeaders: [String: UIView] = [String: UIView]()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let container = self.container {
            addConstraints(for: container)
        }
    }
    
    // MARK: Setup
    public func initialize(with model: TableViewModel, in container: UIView, emptyStateTitle: String, emptyStateMessage: String, emptyStateSystemIconName: String? = "folder.fill.badge.plus") {
        self.removeFromSuperview()
        self.emptyStateTitle = emptyStateTitle
        self.emptyStateMessage = emptyStateMessage
        self.emptyStateIconName = emptyStateSystemIconName ?? "folder.fill.badge.plus"
        self.container = container
        container.addSubview(self)
        self.model = model
        addHeaders() // Add headers also sets up table
        container.layoutIfNeeded()
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
        self.stackView?.removeFromSuperview()
        
        // Create StackView
        let stackView   = UIStackView()
        // Add Subview
        self.headerContainerView.addSubview(stackView)
        // Assign local variable
        self.stackView = stackView
        // StackView options
        stackView.axis  = NSLayoutConstraint.Axis.horizontal
        stackView.distribution  = UIStackView.Distribution.fillProportionally
        stackView.alignment = UIStackView.Alignment.leading
        stackView.spacing   = Table.rowItemSpacing
       
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add Constraints
        stackView.leadingAnchor.constraint(equalTo: self.headerContainerView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.headerContainerView.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: self.headerContainerView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.headerContainerView.bottomAnchor).isActive = true
        
        // Add Labels
        tableHeaders = [String: UIView]()
        for header in model.headers {
            guard let columnPercentWidth: CGFloat = model.relativeSizes[header] else {
                continue
            }
            let label = UILabel()
            stackView.addArrangedSubview(label)
            label.text = model.displayedHeaders.contains(header) ? header : " "
            label.font = Table.headerFont
            label.textAlignment = .left
            
            label.heightAnchor.constraint(equalToConstant: Table.headerLabelHeight).isActive = true
            label.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: columnPercentWidth / 100).isActive = true
            tableHeaders[header] = label
        }
        
        
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
    
    func getEmptyCell(indexPath: IndexPath) -> TableEmptyStateTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "TableEmptyStateTableViewCell", for: indexPath) as! TableEmptyStateTableViewCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let model = self.model, model.rows.count > 0 else  {
            return 1
        }
        return model.rows.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let model = self.model, model.rows.count > 0 else {
            let cell = getEmptyCell(indexPath: indexPath)
            cell.setup(title: emptyStateTitle, message: emptyStateMessage, iconName: emptyStateIconName)
            return cell
        }
        let cell = getRowCell(indexPath: indexPath)
        cell.setup(model: model.rows[indexPath.row], tableHeaders: tableHeaders, columnSizes: model.relativeSizes)
        return cell
    }
    
    
}
