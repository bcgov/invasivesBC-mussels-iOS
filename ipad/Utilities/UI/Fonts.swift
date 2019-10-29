//
//  Fonts.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-10-28.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//
import Foundation
import UIKit

class Fonts {
    
    static func getPrimary(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue", size: size)!
    }
    
    static func getPrimaryBold(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Bold", size: size)!
    }
    
    static func getPrimaryHeavy(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Heavy", size: size)!
    }
    
    static func getPrimaryLight(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Light", size: size)!
    }
    
    static func getPrimaryMedium(size: CGFloat) -> UIFont {
        return UIFont(name: "HelveticaNeue-Medium", size: size)!
    }
}
