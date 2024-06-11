//
//  SecondaryButton.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 11.06.2024.
//

import Foundation
import UIKit

public class SecondaryButton: UIButton {
    
    public var text: String? {
        didSet {
            setTitle(text, for: .normal)
            setTitle(text, for: .selected)
            setTitle(text, for: .highlighted)
        }
    }
    
    public init(text: String = "") {
        super.init(frame: .zero)
        setupUI(text: text)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(text: String) {
        backgroundColor = .secondaryButtonBackgroundColor
        titleLabel?.font = .appFont(weight: .medium, size: 16)
        setTitle(text, for: .normal)
        setTitle(text, for: .selected)
        setTitle(text, for: .highlighted)
        setTitleColor(.secondaryButtonTintColor, for: .normal)
        setTitleColor(.secondaryButtonTintColor, for: .selected)
        setTitleColor(.secondaryButtonTintColor, for: .highlighted)
        
        self.snp.makeConstraints {
            $0.height.equalTo(Constants.Layout.buttonHeight)
        }
        
        layer.cornerRadius = Constants.Layout.buttonCornerRadius
        layer.borderWidth = 1
        /// secondaryButtonTintColor - не работает. Видимо потому что cgColor
        layer.borderColor = UIColor.black.cgColor
        clipsToBounds = true
    }
}
