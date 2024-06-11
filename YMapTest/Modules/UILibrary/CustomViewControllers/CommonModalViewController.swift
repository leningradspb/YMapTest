//
//  CommonModalViewController.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 11.06.2024.
//

import UIKit

public class CommonModalViewController: UIViewController {
    private let mainStack = VerticalStackView(spacing: 0)
    private let labelsStack = VerticalStackView(spacing: 8)
    private let buttonsStack = VerticalStackView(spacing: 20)
    private let titleLabel = TitleLabel()
    private let subtitleLabel = SubtitleLabel()
    private let primaryButton = PrimaryButton()

    private let model: Model
    public init(model: Model) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setupConstraints()
        setupContent()
    }
    
    private func setupConstraints() {
        view.addSubview(mainStack)
        mainStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Constants.Layout.extraVertical)
            $0.leading.equalToSuperview().offset(Constants.Layout.commonHorizontal)
            $0.trailing.equalToSuperview().offset(-Constants.Layout.commonHorizontal)
            $0.bottom.equalToSuperview().offset(-Constants.Layout.extraVertical)
        }
        
        mainStack.addArranged(subviews: [labelsStack, buttonsStack])
        /// костыль чтобы лейблы не растягивались больше собственного размера
        let v = UIView()
        v.backgroundColor = .clear
        labelsStack.addArranged(subviews: [titleLabel, subtitleLabel, v])
        buttonsStack.addArranged(subviews: [primaryButton])
    }
    
    private func setupContent() {
        let title = model.title
        let subtitle = model.subtitle
        let primaryButtonText = model.primaryButtonText
        let secondaryButtonText = model.secondaryButtonText
        let textAlignment = model.textAlignment
        
        if title == nil, subtitle == nil {
            labelsStack.isHidden = true
        }
        
        if primaryButtonText == nil, secondaryButtonText == nil {
            buttonsStack.isHidden = true
        }
        
        titleLabel.isHidden = title == nil
        subtitleLabel.isHidden = subtitle == nil
        primaryButton.isHidden = primaryButtonText == nil
        
        titleLabel.text = title
        subtitleLabel.text = subtitle
        
        if textAlignment != .left {
            titleLabel.textAlignment = textAlignment
            subtitleLabel.textAlignment = textAlignment
        }
        
        primaryButton.text = primaryButtonText
    }
}

public extension CommonModalViewController {
    struct Model {
        let title: String?
        let subtitle: String?
        let primaryButtonText: String?
        let secondaryButtonText: String?
        var textAlignment: NSTextAlignment = .left
    }
}
