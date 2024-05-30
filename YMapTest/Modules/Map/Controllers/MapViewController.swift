//
//  ViewController.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 23.05.2024.
//


protocol MapObjectTapListenerDelegate: AnyObject {
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint)
}

final class MapObjectTapListener: NSObject, YMKMapObjectTapListener {
    
    private weak var delegate: MapObjectTapListenerDelegate?

    init(delegate: MapObjectTapListenerDelegate) {
        self.delegate = delegate
    }

    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        delegate?.onMapObjectTap(with: mapObject, point: point)
        return true
    }
}


import UIKit
import YandexMapsMobile
import SnapKit
import CoreLocation

final class MapViewController: UIViewController {
    private let mapView = YMKMapView(frame: .zero)!
    /// mapView.mapWindow.map
    private lazy var map = mapView.mapWindow.map
    var placemark: YMKPlacemarkMapObject!
    var timer: Timer!
    var repeats = 1000
    var fraction = 0.01
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
        
    private let locationService = LocationService.shared
    /// 59.961075, 30.260612
    let userLocation = CLLocation(latitude: 59.961075, longitude: 30.260612)
    private var currentZoom: Float = Constants.YMakpKit.zoom
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setupLocationService()
        setupUI()
        
        self.updateMap2(by: userLocation)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.addPlaceMark(latitude: 59.961075, longitude: 30.260612)
        })
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
//        mapView.tintColor = .black
        
//        let darkLayer = CALayer()
//        darkLayer.frame = self.view.bounds
//        darkLayer.compositingFilter = "colorBlendMode"
//        darkLayer.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
//        let darkLayer2 = CALayer()
//        darkLayer2.frame = self.view.bounds
//        darkLayer2.compositingFilter = "overlayBlendMode"
//        darkLayer2.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1).cgColor
//        mapView.layer.addSublayer(darkLayer2)
//        mapView.layer.addSublayer(darkLayer)
//        
//        let darkLayer3 = CALayer()
//        darkLayer3.frame = self.view.bounds
//        darkLayer3.compositingFilter = "darkBlendMode"
//        darkLayer3.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8).cgColor
//        mapView.layer.addSublayer(darkLayer3)
        
        
        mapView.mapWindow.map.isNightModeEnabled = true
        
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
//        transportsPinsCollection = map.mapObjects.add()
    }
    
    private func updateMap2(by location: CLLocation) {
        let startLatitude = location.coordinate.latitude
        let startLongitude = location.coordinate.longitude
        let endLocation = locationService.endLocation
        
        DispatchQueue.main.async {
            self.addPlacemarksOnMap(by: location, endLocation: endLocation)
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
        
    }
    
    private func updateMap(by location: CLLocation) {
        let startLatitude = location.coordinate.latitude
        let startLongitude = location.coordinate.longitude
        let endLocation = locationService.endLocation
        
        DispatchQueue.main.async {
            self.addPlacemarksOnMap(by: location, endLocation: endLocation)
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
    
    private func addPlacemarksOnMap(by startLocation: CLLocation, endLocation: CLLocation) {
        let startLatitude = startLocation.coordinate.latitude
        let startLongitude = startLocation.coordinate.longitude
        
        let endLocationLatitude = endLocation.coordinate.latitude
        let endLocationLongitude = endLocation.coordinate.longitude
        // Задание координат точки
          let startPoint = YMKPoint(latitude: startLatitude, longitude: startLongitude)
          let viewStartPlacemark: YMKPlacemarkMapObject = mapView.mapWindow.map.mapObjects.addPlacemark(with: startPoint)
        
        let endPoint = YMKPoint(latitude: endLocationLatitude, longitude: endLocationLongitude)
        let viewEndPlacemark: YMKPlacemarkMapObject = mapView.mapWindow.map.mapObjects.addPlacemark(with: endPoint)
          
        // Настройка и добавление иконки
        viewStartPlacemark.setIconWith(
              UIImage(named: "Basic_green_dot")!, // Убедитесь, что у вас есть иконка для точки
              style: YMKIconStyle(
                  anchor: CGPoint(x: 0.5, y: 0.5) as NSValue,
                  rotationType: YMKRotationType.rotate.rawValue as NSNumber,
                  zIndex: 0,
                  flat: true,
                  visible: true,
                  scale: 0.1,
                  tappableArea: nil
              )
          )
        
        viewEndPlacemark.setIconWith(
              UIImage(named: "Rad-Circle-3")!, // Убедитесь, что у вас есть иконка для точки
              style: YMKIconStyle(
                  anchor: CGPoint(x: 0.5, y: 0.5) as NSValue,
                  rotationType: YMKRotationType.rotate.rawValue as NSNumber,
                  zIndex: 0,
                  flat: true,
                  visible: true,
                  scale: 0.1,
                  tappableArea: nil
              )
          )
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
    
    @objc func updateTimer() {
        if repeats == 0 {
            timer.invalidate()
        } else {
            let startLatitude = 59.961075
            let endLatitude = 59.962990
            let startLongitude = 30.260612
            let endLongitude = 30.247806
            
            let differenceLatitude = (endLatitude - startLatitude) / 500 //* fraction
            let differenceLongitude = (endLongitude - startLongitude) / 500 //* fraction
            fraction += 0.01
            
            print(differenceLatitude, differenceLongitude)
            
            // if use fraction let latitude = startLatitude + differenceLatitude let longitude = startLongitude + differenceLongitude
            let latitude = placemark.geometry.latitude + differenceLatitude
            let longitude = placemark.geometry.longitude + differenceLongitude
            
            self.placemark.geometry = YMKPoint(latitude: latitude, longitude: longitude)
        }
    }
}

extension MapViewController: YMKMapCameraListener {
    func onCameraPositionChanged(with map: YMKMap, cameraPosition: YMKCameraPosition, cameraUpdateReason: YMKCameraUpdateReason, finished: Bool) {
        
    }
}

extension MapViewController: YMKMapSizeChangedListener, YMKMapObjectTapListener {
    
    func onMapWindowSizeChanged(with mapWindow: YMKMapWindow, newWidth: Int, newHeight: Int) {
    }
    
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        if let model = mapObject.userData as? SampleModel {
            print(model)
//            59.961544, 30.257244
//            59.961075, longitude: 30.260612
//            YMKPoint(latitude: 59.961544, longitude: 30.257244)
            //start point 59.961075, longitude: 30.260612
            // end point 59.962990, 30.247806
            
            
            timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
//            UIView.animate(withDuration: 1, animations: {
//                self.placemark.geometry = YMKPoint(latitude: 59.961544, longitude: 30.257244)
//            })
            
        } else {
            print("не модель")
        }
        return true
    }
}


struct SampleModel: Decodable {
    let name: String
    let latitude, longitude: CLLocationDegrees
}
