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
    private let pinImageView = UIImageView(image: UIImage(named: Constants.Icons.selectAddressPin))
    /// стек в котором можно расположить кнопки + - локация и пауза (для паузы надо добавить пустое вью, чтобы соблюсти отступы)
    private let mapButtonsStack = VerticalStackView(spacing: Constants.Layout.mapButtonsStackSpacing)
    private let mapButtonsData = Constants.MapButtons.allCases
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
    private var userLocationDotPlacemark: YMKPlacemarkMapObject?
    private var pinPoint: YMKPoint?
//    private var userLocationPinPlacemark: YMKPlacemarkMapObject?
    
    private let searchManager = YMKSearchFactory.instance().createSearchManager(with: .combined)
    private var suggestSession: YMKSearchSuggestSession!
    private var searchSession: YMKSearchSession?
    
    private var isPinAnimating = false
        
    private let locationService = LocationService.shared
    /// 59.961075, 30.260612
    let userLocation = CLLocation(latitude: 59.961075, longitude: 30.260612)
    private var currentZoom: Float = Constants.YMakpKit.zoom
    private var isInitialMapZoomFinished: Bool = false
    
    private let startModalOnMap = StartModalOnMapVC()
    
    //точка подачи
    private let startPointStack = VerticalStackView(spacing: 2)
    private let startPointConstLabel = SecondaryLabel(text: "Точка подачи", textAlignment: .center, fontSize: 12)
    private let startPointValueLabel = TitleLabel(text: "Восточная 7Г", textAlignment: .center, fontSize: 16)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        locationService.locationUpdatedCompletion = { [weak self] location in
            self?.updateMap2(by: location)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
//            self.addPlaceMark(latitude: 59.961075, longitude: 30.260612)
//            let vc = UIViewController()
//            let rect = UIView()
//            rect.backgroundColor = .primaryColor
//            vc.view.addSubview(rect)
//            let label = UILabel()
//            label.text = "Принять Радищева, 16"
//            label.font = .appFont(weight: .regular, size: 14)
//            
//            rect.snp.makeConstraints {
//                $0.top.equalToSuperview().offset(100)
//                $0.width.height.equalTo(200)
//                $0.centerX.equalToSuperview()
//                $0.bottom.equalToSuperview().offset(-100)
//            }
//            
//            rect.addSubview(label)
//            label.snp.makeConstraints {
//                $0.center.equalToSuperview()
//            }
            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
////                vc.overrideUserInterfaceStyle = .light
//                UIApplication.shared.windows.first!.overrideUserInterfaceStyle = .light
//            })
            
//            self.showFPC(vc: vc)
//            self.presentFPC(contentVC: vc)
//            ModalPresenter.shared.presentModalController(contentVC: vc)
//            let model = CommonModalViewController.Model(title: "Точно хотите отменить заказ?", subtitle: "Если сейчас отменить, поиск новой машины может быть дольше", primaryButtonText: "Не отменять", secondaryButtonText: "Отменить заказ", textAlignment: .center)
//            let vc = CommonModalViewController(model: model)
            
            
            MapStartModalPresenter.shared.presentModalController(contentVC: self.startModalOnMap, state: .intrinsicAndTip(tipFractionalOffset: 130), surfaceViewBackgroundColor: .clear)
//            ModalPresenter.shared.presentModalController(contentVC: vc, isBackdropViewHidden: false)
//            Router.bottomSheet.present(vc)
        })
    }
    
//    private func showFPC(vc: UIViewController) {
//        fpc = FloatingPanelController()
//        
//        // Assign self as the delegate of the controller.
//        fpc.delegate = self // Optional
//        
//        // Set a content view controller.
//        //                    let contentVC = ContentViewController()
//        fpc.set(contentViewController: vc)
//        
//        // Track a scroll view(or the siblings) in the content view controller.
//        //                    fpc.track(scrollView: contentVC.tableView)
//        
//        // Add and show the views managed by the `FloatingPanelController` object to self.view.
//        fpc.addPanel(toParent: self)
//    }
    
//    private func presentFPC(contentVC: UIViewController) {
//
//    }

    private func setupUI() {
        view.backgroundColor = .white
        setupMap()
        setupStartPointView()
        
//        for family in UIFont.familyNames {
//                print("family:", family)
//                for font in UIFont.fontNames(forFamilyName: family) {
//                    print("font:", font)
//                }
//            }
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
        
        // Тёмная тема темная dark mode
//        mapView.mapWindow.map.isNightModeEnabled = true
        
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
        
//        let style = """
//        [{
//            "featureType" : "all",
//            "stylers": {
//                "lightness": "lightness": -0.5
//            }
//        }]
//        """
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
        
        suggestSession = searchManager.createSuggestSession()
        
        setupMapStackView()
        addPinOnMap()
    }
    
    private func addPinOnMap() {
        view.addSubview(pinImageView)
        
        pinImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
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
            UIImage(named: Constants.Icons.userLocationIcon)!, // Убедитесь, что у вас есть иконка для точки
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
        userLocationDotPlacemark = viewStartPlacemark
    }
    
    private func movePinOnMap(by point: YMKPoint, finished: Bool) {
        pinPoint = point
        if finished {
            startPointValueLabel.text = "\(point.latitude)"
        }
        
//        if finished {
//            UIView.animate(withDuration: 0.25, animations: {
//                self.pinImageView.frame.origin.y = self.view.frame.height / 2
//                self.isPinAnimating = false
//            })
//        } else {
//            if !isPinAnimating {
//                UIView.animate(withDuration: 0.5, animations: {
//                    self.pinImageView.frame.origin.y -= Constants.YMakpKit.pinImageViewYOffset
//                    self.isPinAnimating = true
//                })
//            }
//            
//        }
        
        
//        if let userLocationPinPlacemark = userLocationPinPlacemark {
//            self.userLocationPinPlacemark?.geometry = point
//            print(self.userLocationPinPlacemark?.direction)
//            return
//        }
//        
//        let viewStartPlacemark: YMKPlacemarkMapObject = mapView.mapWindow.map.mapObjects.addPlacemark(with: point)
//        // Настройка и добавление иконки
//        viewStartPlacemark.setIconWith(
//            UIImage(named: Constants.Icons.locationPinLight)!, // Убедитесь, что у вас есть иконка для точки
//              style: YMKIconStyle(
//                  anchor: CGPoint(x: 0.5, y: 0.5) as NSValue,
//                  rotationType: YMKRotationType.rotate.rawValue as NSNumber,
//                  zIndex: 0,
//                  flat: true,
//                  visible: true,
//                  scale: 1,
//                  tappableArea: nil
//              )
//          )
//        userLocationPinPlacemark = viewStartPlacemark
    }
    
    /// Точка подачи лейбл
    private func setupStartPointView() {
        view.addSubview(startPointStack)
        startPointStack.addArranged(subviews: [startPointConstLabel, startPointValueLabel])
        
        startPointStack.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Constants.Layout.extraVertical)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func changeModalStateToTip() {
        if MapStartModalPresenter.shared.currentState != .tip {
            MapStartModalPresenter.shared.changeModalState(state: .tip)
        }
    }
    
    private func changeModalStateToFull() {
        if MapStartModalPresenter.shared.currentState != .full {
            MapStartModalPresenter.shared.changeModalState(state: .full)
        }
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
//        print(cameraPosition.target.latitude, cameraPosition.target.longitude, finished)
        movePinOnMap(by: cameraPosition.target, finished: finished)
        if MapStartModalPresenter.shared.isPresentingNow, isInitialMapZoomFinished {
            changeModalStateToTip()
        }
        
//        if finished {
//            searchSession = searchManager.submit(with: cameraPosition.target, zoom: NSNumber(floatLiteral: Double(cameraPosition.zoom)), searchOptions: .init(searchTypes: .geo, resultPageSize: 10, snippets: [], userPosition: userLocationDotPlacemark?.geometry, origin: nil, geometry: true, disableSpellingCorrection: true, filters: nil), responseHandler: {
//                result, error in
//    //            self.handler?(result, error)
////                print(result, error)
//                switch result {
//                case .some(let response):
////                    print(response.metadata.found, "requestText = \(response.metadata.requestText)", "context = \(response.metadata.context)" , "name = \(response.metadata.toponym?.name)", response.collection.boundingBox,  response.collection.metadataContainer, response.metadata.toponymResultMetadata, response.metadata.toponymResultMetadata?.found, response.metadata.toponymResultMetadata?.description, response.metadata.toponymResultMetadata?.responseInfo?.accuracy, response.metadata.toponymResultMetadata, response.collection.children.first?.obj?.name, response.collection.children.count)
////                    response.metadata.toponym?.aref.forEach {
////                        print("$0", $0)
////                    }
////                    $0.obj?.metadataContainer
//                    print(response.collection.children.count)
//                    response.collection.children.forEach {
//                        print($0.obj?.aref.first, $0.obj?.name)
////                        print($0.obj?.attributionMap.values.count)
////                        $0.obj?.attributionMap.forEach {
////                            print($0.key, $0.value)
////                        }
//                    }
//    //                response.items.forEach {
//    //                    print($0.center, $0.displayText, $0.title.text)
//    //                }
//                default:
//                    break
//                }
//            })
//        }
      

//        suggestSession.suggest(withText: "восточна", window: YMKBoundingBox(southWest: cameraPosition.target, northEast: cameraPosition.target), suggestOptions: .init(suggestTypes: .geo, userPosition: userLocationDotPlacemark?.geometry, suggestWords: true), responseHandler: { res, err in
//            print(res, err)
//            switch res {
//            case .some(let response):
//                response.items.forEach {
//                    print($0.center, $0.displayText, $0.title.text)
//                }
//            default:
//                break
//            }
//        })
//        suggestSession.submit(with: cameraPosition.target, zoom: NSNumber(floatLiteral: Double(cameraPosition.zoom)), searchOptions: .init(searchTypes: .geo, resultPageSize: 1.0, snippets: .panoramas, userPosition: userLocationDotPlacemark?.geometry, origin: nil, geometry: true, disableSpellingCorrection: true, filters: nil), responseHandler: { first, second  in
//            print(first, second)
//        })
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


