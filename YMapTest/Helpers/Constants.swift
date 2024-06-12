//
//  Constants.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 23.05.2024.
//

import Foundation
import YandexMapsMobile

struct Constants {
    
    struct Layout {
        /// 24
        static let commonHorizontal: CGFloat = 24
        /// 24
        static let extraVertical: CGFloat = 24
        /// 20
        static let mediumVertical: CGFloat = 20
        /// 16
        static let commonVertical: CGFloat = 16
        /// 44
        static let bottomPadding: CGFloat = 44
        /// 50
        static let mapButton: CGFloat = 50
        /// -30
        static let mapButtonsStackCenterYOffset: CGFloat = -30
        /// 12
        static let mapButtonsStackSpacing: CGFloat = 12
        /// 64
        static let buttonHeight: CGFloat = 64
        /// 32
        static let buttonCornerRadius: CGFloat = 32
        /// 16
        static let cellMediumCornerRadius: CGFloat = 16
        /// 14
        static let primaryButtonIconValue: CGFloat = 14
        /// 12
        static let primaryButtonXIconOffset: CGFloat = 12
    }
    
    struct YMakpKit {
        static let mapKitKey = "26a91d29-9c93-4795-9f82-0e5b9d0fb0a7"
        static let zoom: Float = 18
        static let azimuth: Float = 0
        static let tilt: Float = 0
        static let duration: Float = 1
        static let mapAnimation = YMKAnimation(type: .smooth, duration: 0.3)
    }
    
    struct HardcodedTexts {
        static let alertLocationErrorTitle = "Вы не предоставили доступ к вашей геолокации"
        static let alertLocationErrorMessage = "Поэтому вызовем вам такси от Екатеринбург Арены"
    }
    
    struct Icons {
        static let backToLocationLight = "back_to_current_location_light"
        static let zoomInLight = "zoom_in_light"
        static let zoomOutLight = "zoom_out_light"
        static let userLocationIcon = "user_location_icon"
        static let locationPinLight = "location_pin_light"
        static let primaryButtonNavigateIcon = "primary_button_navigate_icon"
        static let primaryButtonXIcon = "primary_button_x_icon"
        static let lastAddressGridPin = "last_address_grid_pin"
        static let selectAddressPin = "select_address_pin"
        static let carLightTheme = "car_light_theme" 
    }
    
    enum MapButtons: CaseIterable {
        case zoomIn, zoomOut, backToCurrentLocation
       
        var iconName: String {
            switch self {
            case .zoomIn:
                return Constants.Icons.zoomInLight
            case .zoomOut:
                return Constants.Icons.zoomOutLight
            case .backToCurrentLocation:
                return Constants.Icons.backToLocationLight
            }
        }
        
        var tag: Int {
            switch self {
            case .zoomIn:
                return MapButtonTag.zoomIn.rawValue
            case .zoomOut:
                return MapButtonTag.zoomOut.rawValue
            case .backToCurrentLocation:
                return MapButtonTag.backToCurrentLocation.rawValue
            }
        }
        
        enum MapButtonTag: Int {
            case zoomIn, zoomOut, backToCurrentLocation
        }
    }
}
