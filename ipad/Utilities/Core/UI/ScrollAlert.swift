//
//  ScrollAlert.swift
//  ipad
//
//  Created by Paul Garewal on 2024-12-19.
//  Copyright © 2024 Amir Shayegh. All rights reserved.
//

import UIKit

class ScrollableAlertViewController: UIViewController {
    
    private let titleLabel = UILabel()
    private let textView = UITextView()
    private let okButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        // Configure background
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // Container for the alert
        let alertContainer = UIView()
        alertContainer.backgroundColor = .white
        alertContainer.layer.cornerRadius = 12
        alertContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(alertContainer)
        
        // Title label
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textColor = .black
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        alertContainer.addSubview(titleLabel)
        
        // Scrollable text view
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.font = .systemFont(ofSize: 14)
        textView.textColor = .black
        textView.backgroundColor = .clear
        textView.showsVerticalScrollIndicator = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        alertContainer.addSubview(textView)
        
        // OK button
        okButton.setTitle("OK", for: .normal)
        okButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        okButton.setTitleColor(.systemBlue, for: .normal)
        okButton.translatesAutoresizingMaskIntoConstraints = false
        okButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        okButton.backgroundColor = .clear
        alertContainer.addSubview(okButton)
        okButton.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            // Alert container
            alertContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertContainer.widthAnchor.constraint(equalToConstant: 270),
            
            // Title label
            titleLabel.topAnchor.constraint(equalTo: alertContainer.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: alertContainer.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: alertContainer.trailingAnchor, constant: -16),
            
            // Text view
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: alertContainer.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: alertContainer.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(equalToConstant: 200),
            
            // OK button
            okButton.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 8),
            okButton.bottomAnchor.constraint(equalTo: alertContainer.bottomAnchor, constant: -8),
            okButton.leadingAnchor.constraint(equalTo: alertContainer.leadingAnchor),
            okButton.trailingAnchor.constraint(equalTo: alertContainer.trailingAnchor),
            okButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func dismissAlert() {
        dismiss(animated: true)
    }
    
    func configure(title: String, message: String) {
        titleLabel.text = title
        textView.text = message
    }
}
