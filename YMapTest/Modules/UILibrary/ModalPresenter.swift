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
    
    public func presentModalController(contentVC: UIViewController, isRemovalInteractionEnabled: Bool = true, state: ModalState = .intrinsic, isGrabberHandleHidden: Bool = true, isHideByTapGesture: Bool = true) {
        fpc = FloatingPanelController()
        
        switch state {
        case .intrinsic:
            fpc.layout = IntrinsicPanelLayout()
        case .full:
            fpc.layout = FullPanelLayout()
        default:
            fpc.layout = IntrinsicPanelLayout()
        }
        
        fpc.delegate = self // Optional
        fpc.backdropView.backgroundColor = .modalBackViewColor
        fpc.surfaceView.appearance.cornerRadius = ModalPresenter.Constants.surfaceViewCornerRadius
        fpc.surfaceView.grabberHandle.isHidden = isGrabberHandleHidden
        fpc.set(contentViewController: contentVC)
        
        /// скрывать по нажатию на заднее вью
        if isHideByTapGesture {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleBackdropTap))
            fpc.backdropView.addGestureRecognizer(tapGesture)
        }

        fpc.isRemovalInteractionEnabled = isRemovalInteractionEnabled // Optional: Let it removable by a swipe-down

//        rootVC?.present(fpc, animated: true, completion: nil)
        if let rootVC {
            fpc.addPanel(toParent: rootVC)
            fpc.surfaceView.layoutIfNeeded()
            fpc.surfaceView.invalidateIntrinsicContentSize()
        } else {
            print("Нет rootVC в presentModalController")
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
    
    class FullPanelLayout: FloatingPanelLayout {
        public let position: FloatingPanelPosition = .bottom
        public let initialState: FloatingPanelState = .full
        public let anchors: [FloatingPanelState : FloatingPanelLayoutAnchoring] = [
               .full: FloatingPanelLayoutAnchor(absoluteInset: 40, edge: .top, referenceGuide: .superview)
           ]
       }
}


extension ModalPresenter: FloatingPanelControllerDelegate {
    
}

public extension ModalPresenter {
    enum ModalState {
        case full, intrinsic
        case custom(value: CGFloat)
    }
}

private extension ModalPresenter {
    struct Constants {
        static let surfaceViewCornerRadius: CGFloat = 24
    }
}
