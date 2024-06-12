//
//  Extensions.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 23.05.2024.
//

import UIKit

extension UIApplication {
    
    class func getTopViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        } else {
            return nil
        }
    }
    
    class func topViewController(base: UIViewController? = UIWindow.key?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }

    static var topSafeAreaInset: CGFloat {
        key?.safeAreaInsets.top ?? 0
    }

    static var bottomSafeAreaInset: CGFloat {
        key?.safeAreaInsets.bottom ?? 0
    }
}
/// нужно чтобы не было hash коллизий
extension Sequence where Iterator.Element: Hashable {
    var uniqueElements: [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}


extension Collection {
    subscript(safe index: Index?) -> Element? {
        if index == nil {
            return nil
        }
        return indices.contains(index!) ? self[index!] : nil
    }
}
