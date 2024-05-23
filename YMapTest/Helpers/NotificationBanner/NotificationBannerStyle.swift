//
//  NotificationBannerStyle.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 23.05.2024.
//

import UIKit

enum NotificationBannerStyle{
    case succes(text: String)
    case warning(text: String)
    case fail(text: String)
    case info(text: String)
    case isValid(text: String)

    var image: UIImage?{
        switch self{
        case .succes: return UIImage(named: "StatusSuccess")
        case .warning, .isValid: return UIImage(named: "StatusWarning")
        case .fail: return UIImage(named: "StatusFail")
        case .info: return UIImage(named: "StatusInfo")
        }
    }

    var color: UIColor?{
        switch self{
        case .succes: return UIColor.green
        case .warning: return UIColor.orange
        case .fail: return UIColor.red
        case .info: return UIColor.blue
        case .isValid: return UIColor.yellow
        }
    }
}
