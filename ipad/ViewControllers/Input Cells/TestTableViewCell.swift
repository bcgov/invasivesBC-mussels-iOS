//
//  TestTableViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-30.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import UIKit

class TestTableViewCell: UITableViewCell {

    @IBOutlet weak var testButton: UIButton!

    var dropdownDelegate: InputProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func testButtonClickd(_ sender: UIButton) {
        var options: [DropdownModel] = []
        options.append(DropdownModel(display: "Something here"))
        options.append(DropdownModel(display: "Something else here"))
        options.append(DropdownModel(display: "Something more here"))
        options.append(DropdownModel(display: "Another thing"))
        dropdownDelegate!.showDropdownDelegate(items: options, on: sender, callback: { selection in
            sender.setTitle(selection.display, for: .normal)
        })
        
    }
}
