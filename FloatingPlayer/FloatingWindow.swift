//
//  FloatingWindow.swift
//  FloatingPlayer
//
//  Created by SokJinYoung on 01/08/2019.
//  Copyright © 2019 Stone. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum FloatingSettledDirection{
    case left, right
}

class FloatingWindow : UIWindow {
    let disposeBag = DisposeBag()
    
    lazy var topButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.backgroundColor = .lightGray
        button.frame = CGRect(x: 0, y: 0, width: playerButtonWidthHeight, height: playerButtonWidthHeight)
        button.layer.cornerRadius = playerButtonWidthHeight / 2
        button.clipsToBounds = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action:#selector(handlePanGesture(panGesture:)))
        panGesture.cancelsTouchesInView = false
        button.addGestureRecognizer(panGesture)
        
        return button
    }()
    
    var dragging: Bool = false
    
    var winCenterLocYInScreen: CGFloat = (UIScreen.main.bounds.height / 2.0) / UIScreen.main.bounds.height
    
    var settledDirection: FloatingSettledDirection = .left
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        let frame = {
            return CGRect(origin: CGPoint(x: 0, y: UIScreen.main.bounds.height / 2.0), size: CGSize(width: playerButtonWidthHeight, height: playerButtonWidthHeight))
        }()
        super.init(frame: frame)
        
        self.windowLevel = .normal
        self.backgroundColor = .clear
        self.rootViewController = FloatingPlayerViewController()

        if let fltPlayerVC = self.rootViewController as? FloatingPlayerViewController{
            fltPlayerVC.deviceOriChangedSubject.subscribe(onNext: { [weak self] (change) in
                guard let sSelf = self else{ return}
                switch change{
                case .will:
                    sSelf.alpha = 0
                case .did:
                    sSelf.alpha = 1
                    sSelf.center  = {
                        let halfWidthOfWin = sSelf.topButton.frame.size.width / 2.0
                        let centerX = (sSelf.settledDirection == .left) ? halfWidthOfWin : UIScreen.main.bounds.width - halfWidthOfWin
                        
                        let newScreenHeight = UIScreen.main.bounds.height
                        let centerY = sSelf.winCenterLocYInScreen * newScreenHeight
                        
                        return CGPoint(x: centerX, y: centerY)
                    }()
                }
            }).disposed(by: disposeBag)
        }
    }
    
    @objc func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        func getCenterPoint() -> CGPoint {
            let location = panGesture.location(in: topButton)
            let appWindow = (UIApplication.shared.delegate as! AppDelegate).window
            var centerPoint: CGPoint = self.convert(location, to: appWindow)
            //limit
            let viewHalfHeight = topButton.frame.size.height / 2.0
            let topInset = appWindow!.safeAreaInsets.top
            let bottomInset = appWindow!.safeAreaInsets.bottom
            //        let tapbbarHeight: CGFloat = 49.0
            let topLimitY = topInset + viewHalfHeight
            let bottomLimitY = UIScreen.main.bounds.height - bottomInset - viewHalfHeight
            
            if centerPoint.y < topLimitY { centerPoint = CGPoint(x: centerPoint.x, y: topLimitY) }
            else if centerPoint.y > bottomLimitY { centerPoint = CGPoint(x: centerPoint.x, y: bottomLimitY)}
            
            return centerPoint
        }
        
        if panGesture.state == .began {
            dragging = true
        }
        else if panGesture.state == .ended {
            let point = getCenterPoint()
            let viewHalfWidth = topButton.frame.size.width / 2.0
            
            let isOverHalf = point.x <  UIScreen.main.bounds.width / 2.0 ? false : true
            settledDirection = isOverHalf ? .right : .left
            
            //left,right decision
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.beginFromCurrentState,.curveEaseInOut], animations: { [weak self] in
                guard let sSelf = self else {return}
                sSelf.center = isOverHalf ?
                    CGPoint(x: UIScreen.main.bounds.width - viewHalfWidth, y: point.y):
                    CGPoint(x: viewHalfWidth, y: point.y)
            })
            
            winCenterLocYInScreen = center.y / UIScreen.main.bounds.height
        }
        else if panGesture.state == .changed {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.beginFromCurrentState,.curveEaseInOut], animations: {[weak self] in
                guard let sSelf = self else{return}
                sSelf.center = getCenterPoint()
            })
        }
    }
}
