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
    private var columnSizes: [String: CGFloat] = [String: CGFloat]()
    
    // MARK: Class function
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: Setup
    public func setup(model: TableViewRowModel, tableHeaders: [String: UIView], columnSizes: [String: CGFloat]) {
        self.model = model
        self.tableHeaders = tableHeaders
        self.columnSizes = columnSizes
        createStackView()
    }
    
    // MARK: StackView
    private func createStackView() {
        guard let model = self.model else {return}
        self.stackView?.removeFromSuperview()
        // Create StackView
        let stackView   = UIStackView()
        stackView.axis  = NSLayoutConstraint.Axis.horizontal
        stackView.distribution  = UIStackView.Distribution.fillProportionally
        stackView.alignment = UIStackView.Alignment.leading
        stackView.spacing   = Table.rowItemSpacing
        
        guard let last = model.fields.last else {return}
        for item in model.fields {
            guard let columnPercentWidth = columnSizes[item.header] else {
                continue
            }
            let isLast = item.header == last.header
            if item.isButton == true {
                let button = UIButton()
                stackView.addArrangedSubview(button)
                button.heightAnchor.constraint(equalToConstant: Table.rowHeight).isActive = true
                button.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: columnPercentWidth / 100).isActive = true
                
                if isLast {
                    button.widthAnchor.constraint(greaterThanOrEqualTo: stackView.widthAnchor, multiplier: columnPercentWidth / 100).isActive = true
                } else {
                    button.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: columnPercentWidth / 100).isActive = true
                }
                
                button.setTitle(item.value, for: .normal)
                styleHollowButton(button: button)
            } else if let iconColor = item.iconColor {
                let valueStack = UIStackView()
                let itemSpacing = Table.indicatorSize / 2
                valueStack.axis  = NSLayoutConstraint.Axis.horizontal
                valueStack.distribution  = UIStackView.Distribution.fillProportionally
                valueStack.alignment = UIStackView.Alignment.center
                valueStack.spacing   = itemSpacing
                
                let indicatorView = UIView()
                valueStack.addArrangedSubview(indicatorView)
                indicatorView.heightAnchor.constraint(equalToConstant: Table.indicatorSize).isActive = true
                indicatorView.widthAnchor.constraint(equalToConstant: Table.indicatorSize).isActive = true
                indicatorView.backgroundColor = iconColor
                
                let label = UILabel()
                valueStack.addArrangedSubview(label)
                label.heightAnchor.constraint(equalToConstant: Table.rowHeight).isActive = true
                label.widthAnchor.constraint(greaterThanOrEqualToConstant: 1).isActive = true
                label.text = item.value
                label.font = Table.fieldFont
                label.textAlignment = .left
                
                stackView.addArrangedSubview(valueStack)
                
                if isLast {
                    valueStack.widthAnchor.constraint(greaterThanOrEqualTo: stackView.widthAnchor, multiplier: columnPercentWidth / 100).isActive = true
                } else {
                    valueStack.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: columnPercentWidth / 100).isActive = true
                }
                
                makeCircle(view: indicatorView)
            } else {
                let label = UILabel()
                label.heightAnchor.constraint(equalToConstant: Table.rowHeight).isActive = true
                stackView.addArrangedSubview(label)
                
                if isLast {
                    label.widthAnchor.constraint(greaterThanOrEqualTo: stackView.widthAnchor, multiplier: columnPercentWidth / 100).isActive = true
                } else {
                    label.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: columnPercentWidth / 100).isActive = true
                }
                
                label.text = item.value
                label.font = Table.fieldFont
                label.textAlignment = .left
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
