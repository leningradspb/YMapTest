//
//  UIFont+Extension.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 11.06.2024.
//

import UIKit

public extension UIFont {
    
    static func appFont(weight: Weight, size: CGFloat) -> UIFont {
        return manrope(weight: weight, size: size)
    }
    
    static func manrope(weight: Weight, size: CGFloat) -> UIFont {
        switch weight {
        case .regular:
            return UIFont(name: "Manrope-Regular", size: size)!
        case .light:
            return UIFont(name: "Manrope-Light", size: size)!
        case .medium:
            return UIFont(name: "Manrope-Medium", size: size)!
        case .semibold:
            return UIFont(name: "Manrope-SemiBold", size: size)!
        case .bold:
            return UIFont(name: "Manrope-Bold", size: size)!
        case .ultraLight, .thin:
            return UIFont(name: "Manrope-ExtraLight", size: size)!
        case .black, .heavy:
            return UIFont(name: "Manrope-ExtraBold", size: size)!
        default:
            return UIFont(name: "Manrope-Regular", size: size)!
        }
    }
}

