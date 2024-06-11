//
//  PrimaryButton.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 11.06.2024.
//

import UIKit

public class PrimaryButton: UIView {
    private let textLabel = UILabel()
    private let iconImageView = UIImageView()
    
    public var text: String? {
        didSet {
            textLabel.text = text
        }
    }
    
    public init(text: String = "", isCrossIcon: Bool = false, isNavigateIcon: Bool = false) {
        super.init(frame: .zero)
        setupUI(text: text, isCrossIcon: isCrossIcon, isNavigateIcon: isNavigateIcon)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(text: String, isCrossIcon: Bool, isNavigateIcon: Bool) {
        addSubview(textLabel)
        textLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
//            $0.leading.greaterThanOrEqualToSuperview().offset(Constants.Layout.commonHorizontal)
//            $0.trailing.lessThanOrEqualToSuperview().offset(-Constants.Layout.commonHorizontal)
        }
        backgroundColor = .primaryButtonBackgroundColor
        textLabel.textColor = .primaryButtonTintColor
        textLabel.font = .appFont(weight: .medium, size: 16)
        
        self.snp.makeConstraints {
            $0.height.equalTo(Constants.Layout.buttonHeight)
        }
        
        layer.cornerRadius = Constants.Layout.buttonCornerRadius
        clipsToBounds = true
        
        if isCrossIcon {
            setupIconImageView(isImageLeftAligned: false)
        }
        
        if isNavigateIcon {
            setupIconImageView(isImageLeftAligned: true)
        }
    }
    
    private func setupIconImageView(isImageLeftAligned: Bool) {
        addSubview(iconImageView)
        
        if isImageLeftAligned {
            iconImageView.image = UIImage(named: Constants.Icons.primaryButtonNavigateIcon)
            iconImageView.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.width.height.equalTo(Constants.Layout.primaryButtonIconValue)
                $0.leading.equalToSuperview().offset(Constants.Layout.commonHorizontal)
            }
        } else {
            iconImageView.image = UIImage(named: Constants.Icons.primaryButtonXIcon)
            
            iconImageView.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.width.height.equalTo(Constants.Layout.primaryButtonIconValue)
                $0.trailing.equalTo(textLabel.snp.leading).offset(-Constants.Layout.primaryButtonXIconOffset)
            }
        }
    }
}
