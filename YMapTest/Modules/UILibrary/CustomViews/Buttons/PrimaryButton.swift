//
//  PrimaryButton.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 11.06.2024.
//

import UIKit

public class PrimaryButton: UIView {
    private let textLabel = UILabel()
    
    public var text: String? {
        didSet {
            textLabel.text = text
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
        addSubview(textLabel)
        textLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().offset(Constants.Layout.commonHorizontal)
            $0.trailing.lessThanOrEqualToSuperview().offset(-Constants.Layout.commonHorizontal)
        }
        backgroundColor = .primaryButtonBackgroundColor
        textLabel.textColor = .primaryButtonTintColor
        textLabel.font = .appFont(weight: .medium, size: 16)
        
        self.snp.makeConstraints {
            $0.height.equalTo(Constants.Layout.buttonHeight)
        }
        
        layer.cornerRadius = Constants.Layout.buttonCornerRadius
        clipsToBounds = true
    }
}
