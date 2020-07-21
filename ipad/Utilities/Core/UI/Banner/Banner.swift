//
//  Banner.swift
//  ipad
//
//  Created by Amir Shayegh on 2019-11-04.
//  Copyright © 2019 Amir Shayegh. All rights reserved.
//

import Foundation

import Foundation
import UIKit

struct BannerMessage {
    var title: String
    var detail: String
}

class Banner {
    
    public static let displayDuration: TimeInterval = 5
    private static var messages: [BannerMessage] = [BannerMessage]()
    private static var showing = false
    
    public static func show(message title: String, detail: String? = "") {
        if title.isEmpty {return}
        /* Avoid repeating the same messsage */
        if !messages.contains(where: { (message) -> Bool in
            return message.title == title && message.detail == detail
        }) {
            messages.append(BannerMessage(title: title, detail: detail ?? ""))
        }
        
        if !showing {
            recursiveShow()
        }
    }
    
    private static func recursiveShow() {
        guard let message = self.messages.first else {
            self.showing = false
            return
        }
        self.messages.remove(at: 0)
        self.showing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let window = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first {
                let banner: BannerView = UIView.fromNib()
                window.addSubview(banner)
                banner.show(message: message, x: window.frame.origin.x, y: window.frame.origin.y + 20,duration: self.displayDuration, then: {
                    /* Avoid repeating the same messsage */
                    if self.messages.contains(where: { (message) -> Bool in
                        return message.title == message.title && message.detail == message.detail
                    }) {
                        for i in 0...self.messages.count - 1
                            where
                            self.messages[i].title == message.title &&
                            self.messages[i].detail == message.detail
                            {
                            self.messages.remove(at: i)
                        }
                    }
                    self.recursiveShow()
                })
            } else {
                self.showing = false
                return
            }
        }
    }
    
    public static func bannerTextFont() -> UIFont {
        return Fonts.getPrimaryBold(size: 14)
    }
    
    public static func bannerDetailFont() -> UIFont {
        return Fonts.getPrimary(size: 14)
    }
}
