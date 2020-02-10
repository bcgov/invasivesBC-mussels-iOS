//
//  SelectedWaterBodyCollectionViewCell.swift
//  ipad
//
//  Created by Amir Shayegh on 2020-02-09.
//  Copyright © 2020 Amir Shayegh. All rights reserved.
//

import UIKit

class SelectedWaterBodyCollectionViewCell: UICollectionViewCell, Theme {
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var model: DropdownModel?
    private var completion: (() -> Void )?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: Class functions
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let autoLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        
        // Specify you want _full width_
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
        
        // Calculate the size (height) using Auto Layout
        let autoLayoutSize = contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        let autoLayoutFrame = CGRect(origin: autoLayoutAttributes.frame.origin, size: autoLayoutSize)
        
        // Assign the new size to the layout attributes
        autoLayoutAttributes.frame = autoLayoutFrame
        return autoLayoutAttributes
    }
    
    func onSelect() {
        guard let callback = self.completion  else {return}
        callback()
    }
    
    func setup(item: DropdownModel, onRemove: @escaping()-> Void) {
        self.titleLabel.text = item.display
        self.completion = onRemove
        self.model = item
//        let onClickGesture = UITapGestureRecognizer(target: self, action:  #selector (self.selectAction (_:)))
//        self.addGestureRecognizer(onClickGesture)
        style()
    }
    
    @objc func selectAction(_ sender:UITapGestureRecognizer){
        onSelect()
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        onSelect()
    }
    
    func style() {
        roundCorners(layer: container.layer)
        container.layer.borderWidth = 1
        container.layer.borderColor = Colors.primary.cgColor
        removeButton.tintColor = Colors.primary
        self.titleLabel.font = Fonts.getPrimary(size: 17)
    }
    
}
