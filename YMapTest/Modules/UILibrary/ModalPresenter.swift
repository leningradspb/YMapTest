//
//  ModalPresenter.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 11.06.2024.
//

import UIKit
import FloatingPanel

/// Пресентер по отображению модалок
public class ModalPresenter {
    public static let shared = ModalPresenter()
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
    /// устанавливается в present, только для get использвания
    private var modalState: ModalState = .full
    
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
    
    public func presentModalController(contentVC: UIViewController, isRemovalInteractionEnabled: Bool = true, isBackdropViewHidden: Bool = true, state: ModalState = .intrinsic, isGrabberHandleHidden: Bool = true, isHideByTapGesture: Bool = true, surfaceViewBackgroundColor: UIColor = .primaryColor, isLongTopSwipeRestricted: Bool = true, addWithAnimation: Bool = false) {
        fpc = FloatingPanelController()
        self.modalState = state
        fpc.isRemovalInteractionEnabled = isRemovalInteractionEnabled
        switch state {
        case .intrinsic:
            fpc.layout = IntrinsicPanelLayout()
        case .full:
            fpc.layout = FullPanelLayout()
        case .intrinsicAndTip(let absoluteInset):
            fpc.isRemovalInteractionEnabled = false
            fpc.layout = IntrinsicAndTipMapModalPanelLayout(absoluteInset: absoluteInset)
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
public extension ModalPresenter {
    class IntrinsicPanelLayout: FloatingPanelBottomLayout {
        public override var initialState: FloatingPanelState { .full }
        public override var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
            return [
                .full: FloatingPanelIntrinsicLayoutAnchor(fractionalOffset: 0.0, referenceGuide: .superview)
            ]
        }
    }
    
    /// Модалка Куда едем и последние 4 адреса
    class IntrinsicAndTipMapModalPanelLayout: FloatingPanelBottomLayout {
        private let absoluteInset: CGFloat
        public init(absoluteInset: CGFloat) {
            self.absoluteInset = absoluteInset
            super.init()
        }
        
        public override var initialState: FloatingPanelState { .full }
        public override var anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] {
            return [
                .full: FloatingPanelIntrinsicLayoutAnchor(fractionalOffset: 0.0, referenceGuide: .superview),
                .tip: FloatingPanelLayoutAnchor(absoluteInset: absoluteInset, edge: .bottom, referenceGuide: .superview)
            ]
        }
    }
    
    class FullPanelLayout: FloatingPanelLayout {
        public let position: FloatingPanelPosition = .bottom
        public let initialState: FloatingPanelState = .full
        public let anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] = [
               .full: FloatingPanelLayoutAnchor(absoluteInset: 60, edge: .top, referenceGuide: .superview)
           ]
       }
}


extension ModalPresenter: FloatingPanelControllerDelegate {
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
        
        switch modalState {
        case .full:
            let loc = fpc.surfaceLocation
                  let currentY = loc.y
            // TODO: сделать умнее. отвечает за свайп вниз. если офсет больше 220, то сворачивает модалку
            if currentY > 220 {
                fpc.removePanelFromParent(animated: true)
            }
            return
        default:
            break
        }
        
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

public extension ModalPresenter {
    enum ModalState {
        case full, intrinsic, intrinsicAndTip(tipFractionalOffset: CGFloat)
    }
}

public extension ModalPresenter {
    struct Constants {
        static let surfaceViewCornerRadius: CGFloat = 24
    }
}
