//
//  UIView+Extension.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 11.06.2024.
//

import UIKit

extension UIView {
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { self.addSubview($0) }
    }
    
    func roundOnlyTopCorners(radius: CGFloat = 20) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
}

extension UIStackView {
    func addArranged(subviews:[UIView]) {
        subviews.forEach { self.addArrangedSubview($0) }
    }
}
