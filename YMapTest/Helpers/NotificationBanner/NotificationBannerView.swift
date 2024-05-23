//
//  NotificationBannerView.swift
//  YMapTest
//
//  Created by Eduard Kanevskii on 23.05.2024.
//

import UIKit
import SnapKit

protocol NotificationBannerDelegate{
    func timeIsOver(_ sender: NotificationBannerView)
}

final class NotificationBannerView: UIView {
    static let topConstaintIdentifier = "topConstaintIdentifier"
    
    private let titleLabel = UILabel()
    private let imageView = UIImageView()
    private let imageViewSize: CGFloat = 16
    var delegate: NotificationBannerDelegate?
    var timer : Timer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(titleLabel)
        addSubview(imageView)
        
        titleLabel.numberOfLines = 0
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Constants.Layout.commonHorizontal)
            $0.top.equalToSuperview().offset(Constants.Layout.commonVertical)
            $0.bottom.equalToSuperview().offset(-Constants.Layout.commonVertical)
        }
        
        imageView.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(Constants.Layout.commonHorizontal)
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.width.height.equalTo(imageViewSize)
            $0.trailing.equalToSuperview().offset(-Constants.Layout.commonHorizontal)
        }
    }
    
    func configure(_ style: NotificationBannerStyle, delegate: NotificationBannerDelegate){
        self.backgroundColor = .white //style.color
        self.imageView.image = style.image
        self.delegate = delegate
        
        switch style {
        case .succes(let text), .warning(let text), .fail(let text), .info(let text), .isValid(let text):
            self.titleLabel.text = text
        }
    }
    
    public func didShow(){
        self.startTimer()
    }
    
    public func didHide(){
        self.stopTimer()
    }
}


// MARK: - Timer
extension NotificationBannerView{
    private func startTimer() {
        self.timer =  Timer.scheduledTimer(
            timeInterval: TimeInterval(NotificationBanner.shared.bannerViewAppearanceDuration),
            target      : self,
            selector    : #selector(timerAction),
            userInfo    : nil,
            repeats     : false)
    }
    
    private func stopTimer() {
        self.invalidateTimer()
    }
    
    private func invalidateTimer(){
        self.timer?.invalidate()
        self.timer = nil
    }
    
    @objc private func timerAction() {
        self.delegate?.timeIsOver(self)
    }
}

extension NotificationBannerView {
    var topConstraint: NSLayoutConstraint?{
        // array will contain self and all superviews
        var views:[UIView] = []

        // get all superviews
        var view: UIView = self
        while let superview = view.superview {
            views.append(superview)
            view = superview
        }
        
        let result = views.flatMap({ $0.constraints }).first(where: {  constraint in
            return constraint.identifier == NotificationBannerView.topConstaintIdentifier
        })

        return result
    }
}
