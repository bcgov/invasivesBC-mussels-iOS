//
//  WaterbodyTableViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2020-02-06.
//  Copyright © 2020 Amir Shayegh. All rights reserved.
//

import UIKit

class WaterbodyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var checkMarkImageView: UIImageView!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var model: DropdownModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setup(item: DropdownModel, onClick: @escaping()->Void?) {
        self.model = item
        self.titleLabel.text = item.display
        setFlag()
    }
    
    func setFlag() {
        guard let model = self.model else {return}
        let splitByComma = model.display.components(separatedBy: ",")
        if splitByComma.count < 3 { return }
        let countryCity = splitByComma[2]
        let splitCountryCity = countryCity.components(separatedBy: "(")
        if splitCountryCity.count < 2 { return }
        let country = splitCountryCity[0].removeWhitespaces().lowercased()
        flagImageView.image = UIImage(named: country)
    }
}
