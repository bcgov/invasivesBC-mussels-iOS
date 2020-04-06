//
//  Switcher.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-31.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation
import UIKit

class Switcher {
    
    public static func show(items: [String],in view: UIView, initial selected: String?, onChange: @escaping(_ value: String)->Void) -> SwitcherView {
        let switcher: SwitcherView = SwitcherView.fromNib()
        switcher.frame = view.frame
        view.addSubview(switcher)
        switcher.center = view.center
        switcher.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            switcher.centerXAnchor.constraint(equalTo:  view.centerXAnchor),
            switcher.centerYAnchor.constraint(equalTo:  view.centerYAnchor),
            switcher.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            switcher.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            switcher.topAnchor.constraint(equalTo: view.topAnchor),
            switcher.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        switcher.setup(with: items, selected: selected, callBack: onChange)
        
        return switcher
    }
}
