//
//  FormEntryViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-29.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

protocol DropdownProtocol: class {
    func show(items: [DropdownModel], on button: UIButton, callback: @escaping (_ selection: DropdownModel) -> Void)
}

class FormEntryViewController: BaseViewController, DropdownProtocol {
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationController = self.navigationController {
            navigationController.navigationBar.isHidden = false
            navigationController.navigationBar.barStyle = UIBarStyle.default
        }
        setupTableView()
    }
    
    func show(items: [DropdownModel], on button: UIButton, callback:  @escaping (_ selection: DropdownModel) -> Void) {
        self.showDropdown(items: items, on: button) { (result) in
            Alert.show(title: "Selected", message: result!.display)
//            return callback(result!)
        }
    }

}

extension FormEntryViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        register(cell: "TestTableViewCell")
    }
    
    func register(cell name: String) {
        let nib = UINib(nibName: name, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: name)
    }
    
    func getTestTableViewCell(indexPath: IndexPath) -> TestTableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: "TestTableViewCell", for: indexPath) as! TestTableViewCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  getTestTableViewCell(indexPath: indexPath)
        cell.dropdownDelegate = self
        return cell
    }
    
}
