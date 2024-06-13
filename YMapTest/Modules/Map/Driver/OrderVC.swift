//
//  OrderVC.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 13.06.2024.
//

import UIKit

/// Модалка с информацией о заказе. Можно управлять состояниями подача / ожидание (платное / бесплатное) / поездка / приехали
final class OrderVC: UIViewController {
    private let carImageView = UIImageView()
    private let timeLabel = TitleLabel(text: "2:42", numberOfLines: 1, fontSize: 24)
    private let statusLabel = SecondaryLabel(text: "")

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func setNew(orderState: OrderState) {
        print(orderState)
        // TODO: update ui
    }
}

extension OrderVC {
    enum OrderState {
        /// подача машины
        case wayToClient
        /// бесплатное ожидание
        case freeWait
        /// платное ожидание
        case paidWait
        /// в пути
        case onTheWay
        /// остановка
        case pause
        
        var statusText: String {
            switch self {
            case .wayToClient:
                return "Подача"
            case .freeWait:
                return "Бесплатное ожидание"
            case .paidWait:
                return "Платное ожидание"
            case .onTheWay:
                return "В пути"
            case .pause:
                return "Бесплатное ожидание"
            }
        }
    }
}
