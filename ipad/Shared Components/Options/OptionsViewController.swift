//
//  OptionsViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-29.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class OptionsViewController: UIViewController {

    // MARK: Constants
    let optionsCellName = "OptionsTableViewCell"
    let cellHeight: CGFloat = 45
    let suggestedWidth = 280

    // MARK: Variables
    var options: [OptionType] = [OptionType]()
    var completion: ((_ option: OptionType) -> Void )?

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
    }

    // MARK: Functions

    // MARK: Setup
    func setup(options: [OptionType], completion: @escaping (_ option: OptionType) -> Void) -> PopoverSize {
        self.options = options
        self.completion = completion
        setupTable()
        return PopoverSize(width: Double(suggestedWidth), height: Double(estimateHeight()))
    }

    func estimateHeight() -> Int {
        let paddingInCell = 10
        return ((options.count * Int(cellHeight)) + (options.count * paddingInCell))
    }
}

extension OptionsViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTable() {
        if self.tableView == nil {return}
        tableView.delegate = self
        tableView.dataSource = self
        registerCell(name: optionsCellName)
    }

    func registerCell(name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }

    func getCell(indexPath: IndexPath) -> OptionsTableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: optionsCellName, for: indexPath) as! OptionsTableViewCell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var color = Colors.oddCell
//        if indexPath.row % 2 == 0 {
//            color = Colors.evenCell
//        }
        let cell = getCell(indexPath: indexPath)
        cell.setup(option: options[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let callBack = completion {
            self.dismiss(animated: true) {
                 return callBack(self.options[indexPath.row])
            }
        }
    }
}
