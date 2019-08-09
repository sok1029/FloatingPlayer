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

let fltBtnWidthHeight: CGFloat = 43

class FloatingWindow : UIWindow {
    let disposeBag = DisposeBag()
    var settledDirection: FloatingSettledDirection = .left
    var dragging: Bool = false
    private var winCenterLocYInScreen: CGFloat =
        (UIScreen.main.bounds.height / 2.0) / (UIScreen.main.bounds.height)
    
    lazy var topButton: UIButton = {
        let b = UIButton(type: UIButton.ButtonType.custom)
        b.backgroundColor = .lightGray
        b.frame = CGRect(x: 0, y: 0, width: fltBtnWidthHeight, height: fltBtnWidthHeight)
        b.layer.cornerRadius = fltBtnWidthHeight / 2
        b.clipsToBounds = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action:#selector(handleFloating(panGesture:)))
        panGesture.cancelsTouchesInView = false
        b.addGestureRecognizer(panGesture)
        
        return b
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK - Init
    init() {
        let frame = {
            return CGRect(origin: CGPoint(x: 0, y: UIScreen.main.bounds.height / 2.0),
                          size: CGSize(width: fltBtnWidthHeight, height: fltBtnWidthHeight))
        }()
        super.init(frame: frame)
        
        self.windowLevel = .normal
        self.backgroundColor = .clear
        self.rootViewController = FloatingPlayerViewController()

        if let fltPlayerVC = self.rootViewController as? FloatingPlayerViewController{
            fltPlayerVC.deviceOriTransitionSubject.subscribe(onNext: { [weak self] (transition) in
                guard let sSelf = self else{ return }
               
                switch transition{
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
    
    //MARK: -HandleFloating
    @objc func handleFloating(panGesture: UIPanGestureRecognizer) {
        guard let appWindow = (UIApplication.shared.delegate as? AppDelegate)?.window else { return }
        //limit
        let fltHalfHeight = topButton.frame.size.height / 2.0
        
        func getTopMoveLimitCenter() -> CGFloat { return appWindow.safeAreaInsets.top + fltHalfHeight }
        func getBottomMoveLimitCenter() -> CGFloat { return  UIScreen.main.bounds.height - appWindow.safeAreaInsets.bottom - fltHalfHeight }
        
        func getFloatingWindowCenterPoint() -> CGPoint {
            let fingerP: CGPoint = {
                let location = panGesture.location(in: topButton)
                return self.convert(location, to: appWindow)
            }()
            var windowCenterP = fingerP

            if fingerP.y < getTopMoveLimitCenter() { windowCenterP.y = getTopMoveLimitCenter()  }
            else if fingerP.y > getBottomMoveLimitCenter() { windowCenterP.y = getBottomMoveLimitCenter() }
            return windowCenterP
        }
        
        if panGesture.state == .began {
            dragging = true
        }
        else if panGesture.state == .changed {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.beginFromCurrentState,.curveEaseInOut], animations: { [weak self] in
                guard let sSelf = self else{ return }
                sSelf.center = getFloatingWindowCenterPoint()
            })
        }
        else if panGesture.state == .ended {
            let topSettledLimitY: CGFloat = getTopMoveLimitCenter() + 50
            let bottomSettledLimitY: CGFloat = getBottomMoveLimitCenter() - 50
            
            let windowCenterP = getFloatingWindowCenterPoint()
            
            let fltHalfWidth = topButton.frame.size.width / 2.0
            let wasButtonOverHalf =  (windowCenterP.x < (UIScreen.main.bounds.width / 2.0)) ? false: true
            
            let x = wasButtonOverHalf ? UIScreen.main.bounds.width - fltHalfWidth : fltHalfWidth
            var y = windowCenterP.y
            
            if y == getTopMoveLimitCenter() { y = topSettledLimitY }
            else if y == getBottomMoveLimitCenter() { y = bottomSettledLimitY }

            //left,right decision
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.beginFromCurrentState,.curveEaseInOut],
                           animations: { [weak self] in
                self?.center = CGPoint(x: x, y: y)
            })
            { [weak self] (c)  in
                guard let sSelf = self else { return }
                sSelf.dragging = false
                sSelf.settledDirection = wasButtonOverHalf ? .right : .left
                sSelf.winCenterLocYInScreen = sSelf.center.y / UIScreen.main.bounds.height
            }
        }
    }
}
