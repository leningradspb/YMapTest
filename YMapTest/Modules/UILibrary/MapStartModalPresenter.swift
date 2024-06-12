//
//  MapStartModalPresenter.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 12.06.2024.
//

import UIKit
import FloatingPanel

/// Пресентер по отображению модалки на главном экране (она живет всегда, нужно отдельное флоу)
public class MapStartModalPresenter {
    public static let shared = MapStartModalPresenter()
    public var fpc: FloatingPanelController!
    public var isPresentingNow: Bool = false
    public var currentState: FloatingPanelState {
        fpc.state
    }
    /// для ограничения чрезмерного поднятия модалки вверх
    private var isLongTopSwipeRestricted: Bool = true
    /// для ограничения чрезмерного поднятия модалки вверх
    private var initialSurfaceScrollViewOffsetY: CGFloat?
    /// для ограничения чрезмерного поднятия модалки вверх
    private let availableScrollToTopYOffset: CGFloat = 60
    
    private lazy var rootVC: UIViewController? = {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }()
    
    private init() {}
    
    public func presentModalController(contentVC: UIViewController, isRemovalInteractionEnabled: Bool = true, isBackdropViewHidden: Bool = true, state: ModalPresenter.ModalState = .intrinsic, isGrabberHandleHidden: Bool = true, isHideByTapGesture: Bool = true, surfaceViewBackgroundColor: UIColor = .primaryColor, isLongTopSwipeRestricted: Bool = true, addWithAnimation: Bool = false) {
        fpc = FloatingPanelController()
        
        fpc.isRemovalInteractionEnabled = isRemovalInteractionEnabled
        switch state {
        case .intrinsic:
            fpc.layout = ModalPresenter.IntrinsicPanelLayout()
        case .full:
            fpc.layout = ModalPresenter.FullPanelLayout()
        case .intrinsicAndTip(let absoluteInset):
            fpc.isRemovalInteractionEnabled = false
            fpc.layout = ModalPresenter.IntrinsicAndTipMapModalPanelLayout(absoluteInset: absoluteInset)
        }
        
        fpc.delegate = self // Optional
        fpc.backdropView.backgroundColor = .modalBackViewColor
        fpc.backdropView.isHidden = isBackdropViewHidden
        fpc.surfaceView.backgroundColor = surfaceViewBackgroundColor
        if surfaceViewBackgroundColor == .clear {
            fpc.surfaceView.appearance.shadows = []
        } else {
            fpc.surfaceView.appearance.cornerRadius = ModalPresenter.Constants.surfaceViewCornerRadius
        }
        self.isLongTopSwipeRestricted = isLongTopSwipeRestricted
        
        fpc.surfaceView.grabberHandle.isHidden = isGrabberHandleHidden
        fpc.set(contentViewController: contentVC)
        
        /// скрывать по нажатию на заднее вью
        if isHideByTapGesture {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleBackdropTap))
            fpc.backdropView.addGestureRecognizer(tapGesture)
        }

        

//        rootVC?.present(fpc, animated: true, completion: nil)
        if let rootVC {
            fpc.addPanel(toParent: rootVC, animated: addWithAnimation)
            isPresentingNow = true
            if isLongTopSwipeRestricted {
                if initialSurfaceScrollViewOffsetY == nil {
                    initialSurfaceScrollViewOffsetY = fpc.surfaceLocation.y
                }
            }
//            fpc.surfaceView.layoutIfNeeded()
//            fpc.surfaceView.invalidateIntrinsicContentSize()
        } else {
            print("Нет rootVC в presentModalController")
        }
    }
    
    public func changeModalState(state: FloatingPanelState) {
        if let fpc, isPresentingNow {
            fpc.move(to: state, animated: true)
        }
    }

    @objc private func handleBackdropTap() {
        fpc?.removePanelFromParent(animated: true)
    }
}

extension MapStartModalPresenter: FloatingPanelControllerDelegate {
    public func floatingPanelDidEndDragging(_ fpc: FloatingPanelController, willAttract attract: Bool) {
    }
    
    public func floatingPanelWillBeginDragging(_ fpc: FloatingPanelController) {
        if isLongTopSwipeRestricted {
            if initialSurfaceScrollViewOffsetY == nil {
                initialSurfaceScrollViewOffsetY = fpc.surfaceLocation.y
            }
        }
    }
    
    public func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
//        print("floatingPanelDidChangeState")
    }
    
    public func floatingPanelDidMove(_ fpc: FloatingPanelController) {
        if isLongTopSwipeRestricted, let initialSurfaceScrollViewOffsetY {
            let loc = fpc.surfaceLocation
            let currentY = loc.y
            if currentY + availableScrollToTopYOffset < initialSurfaceScrollViewOffsetY  {
                changeModalState(state: .full)
//                fpc.surfaceLocation = CGPoint(x: loc.x, y: initialSurfaceScrollViewOffsetY - availableScrollToTopYOffset)
            }
        }
    }
    
    public func floatingPanelDidRemove(_ fpc: FloatingPanelController) {
        isPresentingNow = false
    }
}
