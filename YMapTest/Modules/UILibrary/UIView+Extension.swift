//
//  UIView+Extension.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 11.06.2024.
//

import UIKit

extension UIView {
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { self.addSubview($0) }
    }
    
    func roundOnlyTopCorners(radius: CGFloat = 20) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
}

extension UIStackView {
    func addArranged(subviews:[UIView]) {
        subviews.forEach { self.addArrangedSubview($0) }
    }
}

// MARK: - addActionOnTap
extension UIView {
    func addActionOnTap(withScaleEffect: Bool = false, _ completion: @escaping () -> Void) {
        let gesture = ButtonTapRecognizer(target: self, action: #selector(fireAction), isScaleEffectOn: withScaleEffect, completion: completion)
        self.addGestureRecognizer(gesture)
    }
    
    @objc private func fireAction(_ sender: ButtonTapRecognizer) {
        switch sender.state {
        case .began:
            UIView.animate(withDuration: 0.2) {
                sender.view?.alpha = 0.8
                sender.view?.subviews.forEach {
                    $0.alpha = 0.8
                }
                if sender.isScaleEffectOn {
                    sender.view?.transform = CGAffineTransformMakeScale(0.9, 0.9)
                }
            }
        case .ended:
            UIView.animate(withDuration: 0.2) {
                sender.view?.alpha = 1
                sender.view?.subviews.forEach {
                    $0.alpha = 1
                }
                if sender.isScaleEffectOn {
                    sender.view?.transform = .identity
                }
            }
            
            if sender.view?.bounds.contains(sender.location(in: sender.view)) == true {
                sender.completion()
            }
        case .cancelled, .failed:
            UIView.animate(withDuration: 0.2) {
                sender.view?.alpha = 1
                sender.view?.subviews.forEach {
                    $0.alpha = 1
                }
                if sender.isScaleEffectOn {
                    sender.view?.transform = .identity
                }
            }
        default:
            ()
        }
    }
}

final class ButtonTapRecognizer: UILongPressGestureRecognizer {
    let completion: () -> Void
    let isScaleEffectOn: Bool
    
    init(target: Any?, action: Selector?, isScaleEffectOn: Bool, completion: @escaping () -> Void) {
        self.completion = completion
        self.isScaleEffectOn = isScaleEffectOn
        super.init(target: target, action: action)
        self.minimumPressDuration = .leastNonzeroMagnitude
    }
}
