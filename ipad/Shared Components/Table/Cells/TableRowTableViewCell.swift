//
//  TableRowTableViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-19.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class TableRowTableViewCell: UITableViewCell, Theme {
    
    // MARK: Constants
    
    
    // MARK: Variables
    private weak var stackView: UIStackView?
    private var model: TableViewRowModel? = nil
    private var tableHeaders: [String: UIView] = [String: UIView]()
    
    // MARK: Class function
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: Setup
    public func setup(model: TableViewRowModel, tableHeaders: [String: UIView]) {
        self.model = model
        self.tableHeaders = tableHeaders
        createStackView()
    }
    
    
    // MARK: StackView
    private func createStackView() {
        guard let model = self.model else {return}
        
        // Create StackView
        let stackView   = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.horizontal
        stackView.distribution  = UIStackView.Distribution.fillProportionally
        stackView.alignment = UIStackView.Alignment.leading
        stackView.spacing   = 16.0
        
        guard let last = model.fields.last else {return}
        for item in model.fields {
            guard let headerView = tableHeaders[item.header] else {
                continue
            }
            if item.isButton == true {
                let button = UIButton()
                
                button.heightAnchor.constraint(equalToConstant: Table.rowHeight).isActive = true
                if item.header == last.header {
                    button.widthAnchor.constraint(greaterThanOrEqualToConstant: headerView.frame.width).isActive = true
                } else {
                    button.widthAnchor.constraint(equalToConstant: headerView.frame.width).isActive = true
                }
                
                button.setTitle(item.value, for: .normal)
                styleHollowButton(button: button)
                stackView.addArrangedSubview(button)
                
            } else if let iconColor = item.iconColor {
                let valueStack = UIStackView()
                valueStack.axis  = NSLayoutConstraint.Axis.horizontal
                valueStack.distribution  = UIStackView.Distribution.fillProportionally
                valueStack.alignment = UIStackView.Alignment.center
                valueStack.spacing   = 8.0
                
                let indicatorView = UIView()
                indicatorView.heightAnchor.constraint(equalToConstant: Table.indicatorSize).isActive = true
                indicatorView.widthAnchor.constraint(equalToConstant: Table.indicatorSize).isActive = true
                indicatorView.backgroundColor = iconColor
                valueStack.addArrangedSubview(indicatorView)
                
                let label = UILabel()
                label.heightAnchor.constraint(equalToConstant: Table.rowHeight).isActive = true
                let headerWidth = headerView.frame.width
                label.widthAnchor.constraint(greaterThanOrEqualToConstant: headerWidth - (Table.indicatorSize + 8)).isActive = true
                label.text = item.value
                label.font = Table.fieldFont
                label.textAlignment = .left
                valueStack.addArrangedSubview(label)
                
                if item.header == last.header {
                    valueStack.widthAnchor.constraint(greaterThanOrEqualToConstant: headerView.frame.width).isActive = true
                } else {
                    valueStack.widthAnchor.constraint(equalToConstant: headerView.frame.width).isActive = true
                }
                
                stackView.addArrangedSubview(valueStack)
                makeCircle(view: indicatorView)
            } else {
                let label = UILabel()
                label.heightAnchor.constraint(equalToConstant: Table.rowHeight).isActive = true
                if item.header == last.header {
                    label.widthAnchor.constraint(greaterThanOrEqualToConstant: headerView.frame.width).isActive = true
                } else {
                    label.widthAnchor.constraint(equalToConstant: headerView.frame.width).isActive = true
                }
                
                label.text = item.value
                label.font = Table.fieldFont
                label.textAlignment = .left
                stackView.addArrangedSubview(label)
            }
        }
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Assign local variable
        self.stackView = stackView
        // Add Subview
        self.addSubview(stackView)
        
        // Add Constraints
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
}
