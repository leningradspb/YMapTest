//
//  LastAddressGridCell.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 12.06.2024.
//

import UIKit

final class LastAddressGridCell: UICollectionViewCell {
    private let labelsStack = VerticalStackView(spacing: 2)
    private let subtitleLabel = SecondaryLabel(fontSize: 12)
    private let titleLabel = TitleLabel(numberOfLines: 2, fontSize: 14)
    private let pinImageView = UIImageView(image: UIImage(named: Constants.Icons.lastAddressGridPin))
    /// 12
    private let verticalImageViewOffset: CGFloat = 12
    /// 62
    private let imageViewWidth: CGFloat = 46
    /// 20
    private let labelTopOffset: CGFloat = 20
    /// 12
    private let labelHorizontalOffset: CGFloat = 12
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func update(with model: StartModalOnMapVC.StartModalOnMapModel) {
        subtitleLabel.text = model.time
        titleLabel.text = model.address
    }
    
    private func setupUI() {
        contentView.backgroundColor = .cellBackgroundColor
        contentView.layer.cornerRadius = Constants.Layout.cellMediumCornerRadius
        contentView.clipsToBounds = true
        
        contentView.addSubviews([pinImageView ,labelsStack])
        
        labelsStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(labelTopOffset)
            $0.leading.equalToSuperview().offset(labelHorizontalOffset)
            $0.trailing.equalToSuperview().offset(labelHorizontalOffset)
        }
        pinImageView.clipsToBounds = true
//        pinImageView.contentMode = .scaleAspectFill
        pinImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(verticalImageViewOffset)
            $0.width.equalTo(imageViewWidth)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-verticalImageViewOffset)
        }
        
        labelsStack.addArranged(subviews: [subtitleLabel, titleLabel])
    }
}
