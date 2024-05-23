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
    private let trafficLabel = UILabel()
    private var trafficLayer : YMKTrafficLayer!
    private let drivingRouter = YMKDirectionsFactory.instance().createDrivingRouter(withType: .combined)
    private let drivingOptions: YMKDrivingOptions = {
        let options = YMKDrivingOptions()
        options.routesCount = 1
        return options
    }()
    private var drivingSession: YMKDrivingSession?
        
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
        
        mapView.addSubview(trafficLabel)
        trafficLabel.layer.cornerRadius = 14
        trafficLabel.clipsToBounds = true
        trafficLabel.textAlignment = .center
        trafficLabel.font = .systemFont(ofSize: 14, weight: .bold)
        trafficLabel.textColor = .black
        
        trafficLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Constants.Layout.commonVertical)
            $0.trailing.equalToSuperview().offset(-Constants.Layout.commonHorizontal)
            $0.width.height.equalTo(28)
        }
        trafficLayer = YMKMapKit.sharedInstance().createTrafficLayer(with: mapView.mapWindow)
        trafficLayer.addTrafficListener(withTrafficListener: self)
        trafficLabel.text = "0"
        trafficLabel.backgroundColor = UIColor.white
        trafficLayer.setTrafficVisibleWithOn(true)
    }
    
    private func updateMap(by location: CLLocation) {
        let startLatitude = location.coordinate.latitude
        let startLongitude = location.coordinate.longitude
        DispatchQueue.main.async {
            self.mapView.mapWindow.map.move(
                    with: YMKCameraPosition(
                        target: YMKPoint(latitude: startLatitude, longitude: startLongitude),
                        zoom: Constants.YMakpKit.zoom,
                        azimuth: Constants.YMakpKit.azimuth,
                        tilt: Constants.YMakpKit.tilt
                    ),
                    animation: YMKAnimation(type: YMKAnimationType.smooth, duration: Constants.YMakpKit.duration),
                    cameraCallback: nil)
        }
        
        let endLocation = locationService.endLocation
        let endLocationLatitude = endLocation.coordinate.latitude
        let endLocationLongitude = endLocation.coordinate.longitude
        let points = [
            YMKRequestPoint(point: YMKPoint(latitude: startLatitude, longitude: startLongitude), type: .waypoint, pointContext: nil, drivingArrivalPointId: nil),
            YMKRequestPoint(point: YMKPoint(latitude: endLocationLatitude, longitude: endLocationLongitude), type: .waypoint, pointContext: nil, drivingArrivalPointId: nil)
        ]
        
        let drivingSession = drivingRouter.requestRoutes(
            with: points,
            drivingOptions: drivingOptions,
            vehicleOptions: .init(vehicleType: .taxi, weight: nil, axleWeight: nil, maxWeight: nil, height: nil, width: nil, length: nil, payload: nil, ecoClass: nil, hasTrailer: nil, buswayPermitted: nil),
            routeHandler: drivingRouteHandler
        )
        self.drivingSession = drivingSession
    }
    
    private func drivingRouteHandler(drivingRoutes: [YMKDrivingRoute]?, error: Error?) {
        if let error {
            // Handle request routes error
            return
        }

        guard let drivingRoutes else {
            return
        }

        let mapObjects = mapView.mapWindow.map.mapObjects
        for route in drivingRoutes {
            mapObjects.addPolyline(with: route.geometry)
        }
    }
    
    private func showUserLocationError() {
//        NotificationBanner.shared.show(.info(text: "Вы не предоставили доступ к геолокации. Пожалуйста, перейдите в настройки"))
//        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
            guard let self = self else { return }
            
            self.showAlert(title: Constants.HardcodedTexts.alertLocationErrorTitle, message: Constants.HardcodedTexts.alertLocationErrorMessage)
        })
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
}

extension MapViewController: YMKTrafficDelegate {
    func onTrafficChanged(with trafficLevel: YMKTrafficLevel?) {
        print(trafficLevel?.description, trafficLevel?.color, trafficLevel?.level)
        
        if trafficLevel == nil {
            return
        }
        trafficLabel.text = String(trafficLevel!.level)
        switch trafficLevel!.color {
        case YMKTrafficColor.red:
            trafficLabel.backgroundColor = UIColor.red
            break
        case YMKTrafficColor.green:
            trafficLabel.backgroundColor = UIColor.green
            break
        case YMKTrafficColor.yellow:
            trafficLabel.backgroundColor = UIColor.yellow
            break
        default:
            trafficLabel.backgroundColor = UIColor.white
            break
        }
    }
    
    func onTrafficLoading() {
        
    }
    
    func onTrafficExpired() {
        
    }
    
    
}
