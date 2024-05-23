//
//  NotificationBanner.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 23.05.2024.
//

import UIKit

final class NotificationBanner {
   
    static var shared: NotificationBanner = NotificationBanner()
    private init() {}
    
    private let bannerOffsetTop = CGFloat(64)
    private let bannerInset = CGFloat(20)
    private let animateDuration = 0.5
    private let bannerAppearanceDuration: TimeInterval = 3
    public var bannerViewAppearanceDuration: TimeInterval{  //старт в начале анимации
        return TimeInterval(animateDuration) + bannerAppearanceDuration
    }
    private var lastBannerView: NotificationBannerView?
    
    static func show(_ style: NotificationBannerStyle) {
        NotificationBanner.shared.show(style)
    }
        
    func show(_ style: NotificationBannerStyle) {
        self.showBanner(style)
    }
 
    private func showBanner(_ style: NotificationBannerStyle, animation:(()->Void)? = nil) {
        
        guard let superView = UIApplication.topViewController()?.view else { return }
        
        let width = superView.bounds.size.width - 2*bannerInset
        
        let bannerView = NotificationBannerView()
        
        bannerView.configure(style, delegate: self)
        bannerView.layer.opacity = 1
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.layer.cornerRadius = 12
        
        let height = bannerView.frame.size.height
        bannerView.frame = CGRect(x: bannerInset, y: -height, width: width, height: height)
        
        superView.addSubview(bannerView)
        superView.bringSubviewToFront(bannerView)
        
        let bannerWidthConstraint = NSLayoutConstraint(item: bannerView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width)
        let bannerCenterXConstraint = NSLayoutConstraint(item: bannerView, attribute: .centerX, relatedBy: .equal, toItem: superView, attribute: .centerX, multiplier: 1, constant: 0)
        let bannerTopConstraint = NSLayoutConstraint(item: bannerView, attribute: .top, relatedBy: .equal, toItem: superView, attribute: .top, multiplier: 1, constant: -height)
        bannerTopConstraint.identifier = NotificationBannerView.topConstaintIdentifier
        
        NSLayoutConstraint.activate([bannerWidthConstraint, bannerCenterXConstraint, bannerTopConstraint])
        
        let viewForRemove = self.lastBannerView
        self.lastBannerView = bannerView
        
        UIView.animate(withDuration: animateDuration, delay: 0, options: [], animations: {
            bannerTopConstraint.constant = self.bannerOffsetTop
            bannerView.frame = CGRect(x: self.bannerInset, y: self.bannerOffsetTop, width: width, height: height)
            bannerView.didShow()
            superView.layoutIfNeeded()
            viewForRemove?.alpha = 0
            viewForRemove?.didHide()
        }, completion: { finished in
            viewForRemove?.removeFromSuperview()
        })
       
        let swipeGestureRecognizerDown = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        swipeGestureRecognizerDown.direction = .up
        bannerView.isUserInteractionEnabled = true
        bannerView.addGestureRecognizer(swipeGestureRecognizerDown)
    }
    
    private func hideBanner(_ bannerView: NotificationBannerView){
        UIView.animate(withDuration: animateDuration, delay: 0, options: [], animations: {
            guard let bannerTopConstraint = bannerView.topConstraint else {return}
            bannerTopConstraint.constant =  -bannerView.frame.height
            bannerView.superview?.layoutIfNeeded()
            bannerView.didHide()
        }, completion: { finished in
            guard let bannerView = self.lastBannerView else {return}
            if finished {
                bannerView.removeFromSuperview()
                self.lastBannerView = nil
            }
        })
    }
    
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer) {
        guard let bannerView = sender.view as? NotificationBannerView else {return}
        self.hideBanner(bannerView)
    }
    
}

extension NotificationBanner: NotificationBannerDelegate{
    func timeIsOver(_ sender: NotificationBannerView){
        self.hideBanner(sender)
    }
}
