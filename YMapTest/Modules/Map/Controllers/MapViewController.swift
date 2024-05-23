//
//  ViewController.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 23.05.2024.
//

import UIKit
import YandexMapsMobile
import SnapKit
import CoreLocation

final class MapViewController: UIViewController {
    private let mapView = YMKMapView(frame: .zero)!
    private let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .black
//        setupMap()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            NotificationBanner.shared.show(.info(text: "Вы не предоставили доступ к геолокации. Пожалуйста, перейдите в настройки"))
        })
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
    
    private func getUserLocation() {
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        } else {
            
        }
    }

}

extension MapViewController: CLLocationManagerDelegate {
    
}
