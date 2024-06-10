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
        static let commonHorizontal: CGFloat = 16
        static let commonVertical: CGFloat = 16
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
}
