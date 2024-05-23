//
//  ViewController.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 23.05.2024.
//

import UIKit
import YandexMapsMobile
import SnapKit

final class MapViewController: UIViewController {
    private let mapView = YMKMapView(frame: .zero)!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .black
        setupMap()
    }
    
    private func setupMap() {
        view.addSubview(mapView)
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        mapView.mapWindow.map.move(
                with: YMKCameraPosition(
                    target: YMKPoint(latitude: 59.935493, longitude: 30.327392),
                    zoom: 15,
                    azimuth: 0,
                    tilt: 0
                ),
                animation: YMKAnimation(type: YMKAnimationType.smooth, duration: 5),
                cameraCallback: nil)
    }

}

