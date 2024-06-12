//
//  DriverMapVC.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 12.06.2024.
//


import UIKit
import YandexMapsMobile
import SnapKit
import CoreLocation

final class DriverMapVC: UIViewController {
    private let mapView = YMKMapView(frame: .zero)!
    private let mapButtonsStack = VerticalStackView(spacing: Constants.Layout.mapButtonsStackSpacing)
    private let mapButtonsData = Constants.MapButtons.allCases
    /// mapView.mapWindow.map
    private lazy var map = mapView.mapWindow.map
    var placemark: YMKPlacemarkMapObject!
    
//    private var transportsPinsCollection: YMKMapObjectCollection!
//    private lazy var mapObjectTapListener = MapObjectTapListener(delegate: self)
    private let trafficLabel = UILabel()
    let placemarkStyle = YMKIconStyle()
//    private var trafficLayer : YMKTrafficLayer!
//    private var layer = YMKLayer()
    private let drivingRouter = YMKDirectionsFactory.instance().createDrivingRouter(withType: .combined)
    private let drivingOptions: YMKDrivingOptions = {
        let options = YMKDrivingOptions()
        options.routesCount = 1
        return options
    }()
    private var drivingSession: YMKDrivingSession?
    private var userLocationDotPlacemark: YMKPlacemarkMapObject?
        
    private let locationService = LocationService.shared
    /// 59.961075, 30.260612
    let userLocation = CLLocation(latitude: 59.961075, longitude: 30.260612)
    private var currentZoom: Float = Constants.YMakpKit.zoom
    private var isInitialMapZoomFinished: Bool = false
    
    /// Выйти на линию / уйти с линии
    private let onLineButton = PrimaryButton(text: "Выйти на линию")
    private var isOnLine = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        locationService.locationUpdatedCompletion = { [weak self] location in
            self?.updateMap2(by: location)
        }

    }

    private func setupUI() {
        view.backgroundColor = .white
        setupMap()
        setupJobButton()
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
    
    private func setupJobButton() {
        view.addSubview(onLineButton)
        
        onLineButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Constants.Layout.commonHorizontal)
            $0.trailing.equalToSuperview().offset(-Constants.Layout.commonHorizontal)
            $0.bottom.equalToSuperview().offset(-Constants.Layout.bottomPadding)
        }
        
        onLineButton.addActionOnTap { [weak self] in
            guard let self = self else { return }
            self.changeOnLineState()
        }
    }
    
    private func changeOnLineState() {
        isOnLine.toggle()
        if isOnLine {
            onLineButton.text = "Уйти с линии"
        } else {
            onLineButton.text = "Выйти на линию"
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
//        trafficLayer = YMKMapKit.sharedInstance().createTrafficLayer(with: mapView.mapWindow)
//        trafficLayer.addTrafficListener(withTrafficListener: self)
        trafficLabel.text = "0"
        trafficLabel.backgroundColor = UIColor.white
//        trafficLayer.setTrafficVisibleWithOn(true)
        
        mapView.mapWindow.map.addCameraListener(with: self)

        let style = """
        [
            {
                "elements": "geometry.fill.pattern",
                        "stylers": {
                                        "saturation": -0.75
                                    }
            },
            {
                "elements": "geometry.outline",
                        "stylers": {
                                        "saturation": -0.75
                                    }
            },
            {
                "elements": "geometry.fill",
                        "stylers": {
                                        "saturation": -0.95,
                                "lightness": 0.55
                                    }
            },
            {
                "elements": "label.text.fill",
                        "stylers": {
                                        "saturation": -0.75
                                    }
            },
            {
                "elements": "label.icon",
                    "stylers": {
                                    "saturation": -0.75
                                }
        }
        ]
"""
//        "tags": {
//            "all": ["road", "landscape", "water", "poi"]
//        },
        mapView.mapWindow.map.setMapStyleWithStyle(style)
        
        
        
        setupMapStackView()
    }
    
    private func setupMapStackView() {
        view.addSubview(mapButtonsStack)
        
        for index in 0..<mapButtonsData.count {
            let button = UIButton()
            let mapButtonData = mapButtonsData[index]
            let iconName = mapButtonData.iconName
            let tag = mapButtonData.tag
            button.setImage(UIImage(named: iconName), for: .normal)
            button.tag = tag
            button.snp.makeConstraints {
                $0.width.height.equalTo(Constants.Layout.mapButton)
            }
            button.addTarget(self, action: #selector(mapButtonTapped), for: .touchUpInside)
            mapButtonsStack.addArrangedSubview(button)
        }
        
        mapButtonsStack.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-Constants.Layout.commonHorizontal)
            $0.centerY.equalToSuperview().offset(Constants.Layout.mapButtonsStackCenterYOffset)
        }
    }
    
    private func updateMap2(by location: CLLocation) {
        let startLatitude = location.coordinate.latitude
        let startLongitude = location.coordinate.longitude
//        let endLocation = locationService.endLocation
//        print(startLatitude, startLongitude)
        DispatchQueue.main.async {
//            let userLocationView = YMKUserLocationView()
//            self.onObjectAdded(with: userLocationView)
            self.addUserLocationOnMap(by: location)
            self.mapView.mapWindow.map.move(
                    with: YMKCameraPosition(
                        target: YMKPoint(latitude: startLatitude, longitude: startLongitude),
                        zoom: Constants.YMakpKit.zoom,
                        azimuth: Constants.YMakpKit.azimuth,
                        tilt: Constants.YMakpKit.tilt
                    ),
                    animation: YMKAnimation(type: YMKAnimationType.smooth, duration: Constants.YMakpKit.duration),
                    cameraCallback: { [weak self] finished in
                        guard let self = self else { return }
                        print("finished", finished)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute:  {
                            self.isInitialMapZoomFinished = true
                        })
                        
                    })
        }
        
//        let endLocationLatitude = endLocation.coordinate.latitude
//        let endLocationLongitude = endLocation.coordinate.longitude
//        let points = [
//            YMKRequestPoint(point: YMKPoint(latitude: startLatitude, longitude: startLongitude), type: .waypoint, pointContext: nil, drivingArrivalPointId: nil),
//            YMKRequestPoint(point: YMKPoint(latitude: endLocationLatitude, longitude: endLocationLongitude), type: .waypoint, pointContext: nil, drivingArrivalPointId: nil)
//        ]
        
    }
    
    private func updateMap(by location: CLLocation) {
        let startLatitude = location.coordinate.latitude
        let startLongitude = location.coordinate.longitude
        let endLocation = locationService.endLocation
        
        DispatchQueue.main.async {
//            self.addPlacemarksOnMap(by: location, endLocation: endLocation)
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
    
    func addPlaceMark(latitude: Double, longitude: Double) {
//        transportsPinsCollection.clear()
//        let placemark = transportsPinsCollection.addPlacemark()

//        Log.debug("WS Route number: \(model.routeNumber); routeUUID: \(model.routeUUID ?? "nil"); points \(model.routePoints.count)", printPath: false)
        let mapObjects = self.mapView.mapWindow.map.mapObjects
        let point = YMKPoint(latitude: latitude, longitude: longitude)
                    
        placemark = mapObjects.addPlacemark(with: point, image: UIImage(named: "busS")!)
        placemark.geometry = point
//        placemark.userData = MarkerUserData(id: Int(hit.id!)!, description: hit.plate!)
//        placemark.isDraggable = false
        placemark.addTapListener(with: self)
                    
//        mapObjects.addListener(with: self)

//        placemark.geometry = .init(latitude: latitude, longitude: longitude)
//        placemark.addTapListener(with: mapObjectTapListener)
//        placemark.setViewWithView(YRTViewProvider(uiView: view), style: placemarkStyle)
//        placemark.setViewWithView(view, style: placemarkStyle)
        // 59.961307, longitude: 30.258416
        let model = SampleModel(name: "Name", latitude: latitude, longitude: longitude)
        placemark.userData = model
    }
    
    func move(to geometry: YMKGeometry, zoom: Float? = nil) {
        //        YMKCameraPosition(
        //        mapView.mapWindow.map.position
        var cameraPosition = map.cameraPosition(with: geometry)
        cameraPosition = YMKCameraPosition(
            target: cameraPosition.target,
            zoom: zoom ?? cameraPosition.zoom,
            azimuth: cameraPosition.azimuth,
            tilt: cameraPosition.tilt
        )
        currentZoom = cameraPosition.zoom
        map.move(with: cameraPosition, animation: Constants.YMakpKit.mapAnimation)
    }
    
    private func addUserLocationOnMap(by startLocation: CLLocation) {
        if let userLocationDotPlacemark = userLocationDotPlacemark {
            mapView.mapWindow.map.mapObjects.remove(with: userLocationDotPlacemark)
        }
        
        let startLatitude = startLocation.coordinate.latitude
        let startLongitude = startLocation.coordinate.longitude
        
        // Задание координат точки
        let startPoint = YMKPoint(latitude: startLatitude, longitude: startLongitude)
        let viewStartPlacemark: YMKPlacemarkMapObject = mapView.mapWindow.map.mapObjects.addPlacemark(with: startPoint)
          
        // Настройка и добавление иконки
        viewStartPlacemark.setIconWith(
            UIImage(named: Constants.Icons.carLightTheme)!, // Убедитесь, что у вас есть иконка для точки
              style: YMKIconStyle(
                  anchor: CGPoint(x: 0.5, y: 0.5) as NSValue,
                  rotationType: YMKRotationType.rotate.rawValue as NSNumber,
                  zIndex: 0,
                  flat: true,
                  visible: true,
                  scale: 0.7,
                  tappableArea: nil
              )
          )
        userLocationDotPlacemark = viewStartPlacemark
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
    
    private func changeZoom(by amount: Float) {
        map.move(
            with: YMKCameraPosition(
                target: map.cameraPosition.target,
                zoom: map.cameraPosition.zoom + amount,
                azimuth: map.cameraPosition.azimuth,
                tilt: map.cameraPosition.tilt
            ),
            animation: YMKAnimation(type: .smooth, duration: 1.0)
        )
    }
    
    @objc private func mapButtonTapped(sender: UIButton) {
        print(sender.tag)
        switch sender.tag {
        case Constants.MapButtons.MapButtonTag.zoomIn.rawValue:
            print("zoomIn")
            changeZoom(by: 1)
        case Constants.MapButtons.MapButtonTag.zoomOut.rawValue:
            print("zoomOut")
            changeZoom(by: -1)
        case Constants.MapButtons.MapButtonTag.backToCurrentLocation.rawValue:
            print("backToCurrentLocation")
            if let target = userLocationDotPlacemark?.geometry {
                map.move(
                    with: YMKCameraPosition(
                        target: target,
                        zoom: map.cameraPosition.zoom,
                        azimuth: map.cameraPosition.azimuth,
                        tilt: map.cameraPosition.tilt
                    ),
                    animation: YMKAnimation(type: .smooth, duration: 1.0)
                )
            }
        default:
            print("Нет тэга для mapButton")
            break
        }
    }
}

extension DriverMapVC: YMKTrafficDelegate {
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

extension DriverMapVC: YMKMapCameraListener {
    func onCameraPositionChanged(with map: YMKMap, cameraPosition: YMKCameraPosition, cameraUpdateReason: YMKCameraUpdateReason, finished: Bool) {
//        print(cameraPosition.target.latitude, cameraPosition.target.longitude, finished)
        
    }
}

extension DriverMapVC: YMKMapSizeChangedListener, YMKMapObjectTapListener {
    
    func onMapWindowSizeChanged(with mapWindow: YMKMapWindow, newWidth: Int, newHeight: Int) {
    }
    
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        return true
    }
//        if let model = mapObject.userData as? SampleModel {
//            print(model)
////            59.961544, 30.257244
////            59.961075, longitude: 30.260612
////            YMKPoint(latitude: 59.961544, longitude: 30.257244)
//            //start point 59.961075, longitude: 30.260612
//            // end point 59.962990, 30.247806
//            
//            
////            timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
////            UIView.animate(withDuration: 1, animations: {
////                self.placemark.geometry = YMKPoint(latitude: 59.961544, longitude: 30.257244)
////            })
//            
//        } else {
//            print("не модель")
//        }
//        return true
//    }
}




