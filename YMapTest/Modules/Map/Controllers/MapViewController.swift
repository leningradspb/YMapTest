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
    private let locationService = LocationService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationService()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .black
        setupMap()
    }
    
    private func setupLocationService() {
        locationService.locationErrorCompletion = { [weak self] in
            guard let self = self else { return }
            self.updateMap(by: self.locationService.defaultUserLocation)
            self.showUserLocationError()
        }
        
        locationService.locationUpdatedCompletion = { [weak self] userLocation in
            guard let self = self else { return }
            self.updateMap(by: userLocation)
        }
    }
    
    private func setupMap() {
        view.addSubview(mapView)
        
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func updateMap(by location: CLLocation) {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        mapView.mapWindow.map.move(
                with: YMKCameraPosition(
                    target: YMKPoint(latitude: latitude, longitude: longitude),
                    zoom: Constants.YMakpKit.zoom,
                    azimuth: Constants.YMakpKit.azimuth,
                    tilt: Constants.YMakpKit.tilt
                ),
                animation: YMKAnimation(type: YMKAnimationType.smooth, duration: Constants.YMakpKit.duration),
                cameraCallback: nil)
    }
    
    private func showUserLocationError() {
//        NotificationBanner.shared.show(.info(text: "Вы не предоставили доступ к геолокации. Пожалуйста, перейдите в настройки"))
//        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
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
