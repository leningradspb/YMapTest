//
//  SecondaryButton.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 11.06.2024.
//

import UIKit

public class SecondaryButton: UIView {
    
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
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let traitCollection = self.traitCollection
        let borderColor = UIColor.secondaryButtonTintColor.resolvedColor(with: traitCollection).cgColor
        layer.borderColor = borderColor
    }
    
    private func setupUI(text: String) {
        backgroundColor = .secondaryButtonBackgroundColor
        addSubview(textLabel)
        textLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().offset(Constants.Layout.commonHorizontal)
            $0.trailing.lessThanOrEqualToSuperview().offset(-Constants.Layout.commonHorizontal)
        }
        backgroundColor = .secondaryButtonBackgroundColor
        textLabel.textColor = .secondaryButtonTintColor
        textLabel.font = .appFont(weight: .medium, size: 16)
        textLabel.text = text
        
        self.snp.makeConstraints {
            $0.height.equalTo(Constants.Layout.buttonHeight)
        }
        
        layer.cornerRadius = Constants.Layout.buttonCornerRadius
        layer.borderWidth = 1
        clipsToBounds = true
    }
}
