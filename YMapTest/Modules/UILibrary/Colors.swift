//
//  Colors.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 11.06.2024.
//

import UIKit

public extension UIColor {
    /// Основной цвет (темная тема = черный, светлая - белый)
    static var primaryColor: UIColor = {
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
            if UITraitCollection.userInterfaceStyle == .dark {
                /// Return the color for Dark Mode
                return .mainBlack
            } else {
                /// Return the color for Light Mode
                return .mainWhite
            }
        }
    }()
}

private extension UIColor {
    /// #070707
    static let mainBlack = UIColor(hex: "#070707")
    
    /// #FFFFFF
    static let mainWhite = UIColor(hex: "#FFFFFF")
}
