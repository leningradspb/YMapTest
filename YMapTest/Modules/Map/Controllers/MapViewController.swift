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
        
        getUserLocation()
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
    
    private func getUserLocation() {
        locationManager.requestWhenInUseAuthorization()
        
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.locationManager.startUpdatingLocation()
            } else {
                DispatchQueue.main.async {
                    self.showUserLocationError()
                }
            }
        }
    }
    
    private func showUserLocationError() {
        NotificationBanner.shared.show(.info(text: "Вы не предоставили доступ к геолокации. Пожалуйста, перейдите в настройки"))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
            guard let self = self else { return }
            
            self.showAlert(title: "Вы не предоставили доступ к вашей геолокации", message: "Поэтому вызовем вам такси от Екатеринбург Арены")
        })
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    // do stuff
                }
            }
        }
        if status == .denied {
            showUserLocationError()
        }
    }
}
