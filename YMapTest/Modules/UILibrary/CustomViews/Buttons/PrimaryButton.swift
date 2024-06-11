//
//  PrimaryButton.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 11.06.2024.
//

import UIKit

public class PrimaryButton: UIButton {
    
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
        backgroundColor = .primaryButtonBackgroundColor
        titleLabel?.font = .appFont(weight: .medium, size: 16)
        setTitle(text, for: .normal)
        setTitle(text, for: .selected)
        setTitle(text, for: .highlighted)
        setTitleColor(.primaryButtonTintColor, for: .normal)
        setTitleColor(.primaryButtonTintColor, for: .selected)
        setTitleColor(.primaryButtonTintColor, for: .highlighted)
        
        self.snp.makeConstraints {
            $0.height.equalTo(Constants.Layout.buttonHeight)
        }
        
        layer.cornerRadius = Constants.Layout.buttonCornerRadius
        clipsToBounds = true
    }
}
