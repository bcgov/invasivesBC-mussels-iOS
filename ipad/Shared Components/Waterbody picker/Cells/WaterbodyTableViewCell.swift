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
    
    private var model: DropdownModel?
    private var completion: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func onSelect() {
        guard let callback = self.completion  else {return}
        callback()
    }
    
    func setup(item: DropdownModel, onClick: @escaping()->Void) {
        self.model = item
        self.titleLabel.text = item.display
        self.completion = onClick
        let onClickGesture = UITapGestureRecognizer(target: self, action:  #selector (self.selectAction (_:)))
        self.addGestureRecognizer(onClickGesture)
        setFlag()
    }
    
    @objc func selectAction(_ sender:UITapGestureRecognizer){
        onSelect()
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
