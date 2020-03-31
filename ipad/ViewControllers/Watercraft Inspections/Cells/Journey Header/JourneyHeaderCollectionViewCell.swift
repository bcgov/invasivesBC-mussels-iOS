//
//  JourneyHeaderCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2020-02-18.
//  Copyright © 2020 Amir Shayegh. All rights reserved.
//

import UIKit

class JourneyHeaderCollectionViewCell: UICollectionViewCell, Theme {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewMapButton: UIButton!
    
    private var callback: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func viewMapClicked(_ sender: UIButton) {
        guard let callback = self.callback else {return}
        callback()
    }
    
    func setup(onViewMap: @escaping()->Void) {
        self.callback = onViewMap
        style()
    }
    
    private func style() {
        styleSectionTitle(label: titleLabel)
        viewMapButton.tintColor = Colors.primary
        styleHollowButton(button: viewMapButton)
    }

}
