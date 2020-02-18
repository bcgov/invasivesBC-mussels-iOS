//
//  PDFViewer.swift
//  ipad
//
//  Created by Amir Shayegh on 2020-02-18.
//  Copyright © 2020 Amir Shayegh. All rights reserved.
//

import UIKit
import Modal
import PDFKit

class PDFViewer: ModalView, Theme {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var titleLabel: UILabel!
    
    
    @IBAction func closeClicked(_ sender: Any) {
        remove()
    }
    
    deinit {
        print("de-init PDF viewer")
    }
    
    // MARK: Entry Point
    func initialize(name: String? = "", file path: URL) {
        setSmartSizingWith(horizontalPadding: 0, verticalPadding: 32)
        style()
        present()
        titleLabel.text = name ?? ""
        if let pdfDocument = PDFDocument(url: path) {
            pdfView.displayMode = .singlePageContinuous
            pdfView.autoScales = true
            pdfView.displayDirection = .vertical
            pdfView.document = pdfDocument
        }
    }
    
    func style() {
        self.backgroundColor = Colors.primary
        self.closeButton.tintColor = UIColor.white
        styleSubHeader(label: titleLabel)
        titleLabel.textColor = UIColor.white
        roundCorners(layer: self.layer)
    }
}
