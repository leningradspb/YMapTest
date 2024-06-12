//
//  LastAddressGridCell.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 12.06.2024.
//

import UIKit

final class LastAddressGridCell: UICollectionViewCell {
    private let pinImageView = UIImageView(image: UIImage(named: Constants.Icons.lastAddressGridPin))
    func update(with model: StartModalOnMapVC.StartModalOnMapModel) {
        print(model.address)
        contentView.backgroundColor = .yellow
    }
}
