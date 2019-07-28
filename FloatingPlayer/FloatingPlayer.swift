
//  Created by Ali Pourhadi on 2017-05-07.
//  Copyright © 2019 Stone. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

enum FloatingType{
    case left,right
}

class FloatingWindow : UIWindow {
    public var topView : UIView = UIView()
    lazy var pointInsideCalled : Bool = true
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.point(inside: point, with: event) {
            self.pointInsideCalled = true
            return topView
        }
        if pointInsideCalled {
            self.pointInsideCalled = false
            return topView
        }
        return nil
    }
}

public class FloatingPlayer {
    let disposeBag = DisposeBag()
    
    private var floatingWindow: FloatingWindow?
    private var appWindow: UIWindow?
    private var dragging: Bool = false
    private var floatingButton: UIButton!
    private var isShowing = false
    private var playerSuperView: UIView?
    private var playerView: PlayerView?
    private var floatingPlayerViewController: FloatingPlayerViewController?
    
    var delegate: PlayerEventDelegate?
    var floatingType: FloatingType = .left
    var floatingLocationYInScreen: CGFloat = 0
    var isPlaying: Bool = false
    var floatingImage: UIImage?

    public init(imgName: String? = nil) {
        self.appWindow = UIApplication.shared.keyWindow
        //Button
        let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
        button.backgroundColor = .yellow
        button.frame = CGRect(x: 0, y: 0, width: playerButtonWidthHeight, height: playerButtonWidthHeight)
        button.layer.cornerRadius = playerButtonWidthHeight / 2
        button.clipsToBounds = true
        button.rx.controlEvent([.touchUpInside])
            .subscribe(onNext: { [weak self]  in
                self?.playerBtnTouched()
            })
            .disposed(by: disposeBag)
        let panGesture = UIPanGestureRecognizer(target: self, action:#selector(handlePanGesture(panGesture:)))
        panGesture.cancelsTouchesInView = false
        button.addGestureRecognizer(panGesture)
        
        self.floatingButton = button
        
        if let imgName = imgName{
            let image = UIImage(named: imgName)
            button.setImage(image, for: .normal)
            floatingImage = image
        }
        //floatingWindow
        makeFloatingView(with: button)
        
        floatingPlayerViewController?.currentOrientationSubject.subscribe(onNext: { [weak self] (orientation) in
            guard let strongSelf = self else{ return}
            strongSelf.floatingWindow?.alpha = 0
            
        }).disposed(by: disposeBag)
        // when transitiong orientation window's center auto change by system.
        // so setting new frame after transitioning by delay operator

        floatingPlayerViewController?.currentOrientationSubject.delay(0.35, scheduler:  MainScheduler.instance).subscribe(onNext: { [weak self] (orientation) in
            guard let strongSelf = self else{ return}
            strongSelf.floatingWindow!.center  = strongSelf.getSettledFloatingWindowCenterPoint()
            UIView.animate(withDuration: 0.05, delay:0.0,animations: {
                strongSelf.floatingWindow?.alpha = 1
            })

        }).disposed(by: disposeBag)
    }
    
    private func makeFloatingView(with button: UIButton){
        let window =  FloatingWindow(frame: CGRect.init(origin: CGPoint(x: 0, y: getScreenHeight() / 2), size: button.frame.size))
        floatingPlayerViewController = FloatingPlayerViewController()
        window.rootViewController = floatingPlayerViewController
        window.topView = button
        window.windowLevel = .normal
        window.backgroundColor = .clear
        floatingLocationYInScreen = getLocationYInScreen(view: window)
        floatingWindow = window
    }
    
    public func show() {
        if self.isShowing { return }
        self.floatingWindow?.makeKeyAndVisible()
        self.floatingWindow?.addSubview(self.floatingButton)
        self.isShowing = true
        floatingWindow?.isHidden = false
    }
    
    public func hide() {
        self.isShowing = false
        floatingWindow?.isHidden = true
    }
    
    public func getFloatingViewFrame() -> CGRect{
        let point = (self.floatingButton?.convert(self.floatingButton.frame.origin, to: self.appWindow))!
        return CGRect(x: point.x, y: point.y, width: floatingButton.frame.width, height: floatingButton.frame.height)
    }
    
    @objc private func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        if panGesture.state == .began {
            dragging = true
        }
        else if panGesture.state == .ended {
            let location = panGesture.location(in: self.floatingButton)
            let point = getFloatingWindowCenterPoint(with: location)
            let viewHalfWidth = self.floatingButton.frame.size.width / 2.0
            //left,right decision
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.beginFromCurrentState,.curveEaseInOut], animations: { [weak self] in
                guard let strongSelf = self else {return}
                let isOverHalf = point.x < strongSelf.getScreenWidth() / 2.0 ? false : true
                strongSelf.floatingType = isOverHalf ? .right : .left
                
                if let window = strongSelf.floatingWindow{
                    window.center = isOverHalf ? CGPoint(x: strongSelf.getScreenWidth() - viewHalfWidth, y: point.y): CGPoint(x: viewHalfWidth, y: point.y)
                    strongSelf.floatingLocationYInScreen = strongSelf.getLocationYInScreen(view: window)
                }
            })
        }
        else if panGesture.state == .changed {
            let translation = panGesture.location(in: self.floatingButton)
            self.viewDidMove(to: translation)
        }
    }
    
    // Handleing movement of view
    private func viewDidMove(to location:CGPoint) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.beginFromCurrentState,.curveEaseInOut], animations: {[weak self] in
            guard let strongSelf = self else{return}
            let point = strongSelf.getFloatingWindowCenterPoint(with: location)
            strongSelf.floatingWindow?.center = point
        })
    }
    
    private func getFloatingWindowCenterPoint(with location: CGPoint) -> CGPoint{
        var centerPoint: CGPoint = (floatingWindow?.convert(location, to: appWindow))!
        //limit
        let viewHalfHeight = floatingButton.frame.size.height / 2.0
        let topInset = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
        let bottomInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        //        let tapbbarHeight: CGFloat = 49.0
        let topLimitY = topInset + viewHalfHeight
        let bottomLimitY = getScreenHeight() - bottomInset - viewHalfHeight
        
        if centerPoint.y > bottomLimitY{
            centerPoint = CGPoint(x: centerPoint.x, y: bottomLimitY)
        }
        else if centerPoint.y < topLimitY{
            centerPoint = CGPoint(x: centerPoint.x, y: topLimitY)
        }

        return centerPoint
    }
    
    private func getSettledFloatingWindowCenterPoint() -> CGPoint{
        let halfWidthOfWindow = self.floatingWindow!.topView.frame.size.width / 2.0
        let centerX = (floatingType == .left) ? halfWidthOfWindow : getScreenWidth() - halfWidthOfWindow
        let centerY = floatingLocationYInScreen * getScreenHeight()
        
        return CGPoint(x: centerX, y: centerY)
    }

    
    private func playerBtnTouched(){
        if !dragging{
            playerControllerShow()
        }
        dragging = false
    }
    
    private func playerControllerShow() {
        if isShowing{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if let window = appDelegate.window{
                hide()
                addPlayerView(floatingType)
                if let image = floatingImage{
                    playerView!.setImage(image: image)
                }
                //background diableView
                let view = UIView(frame: window.bounds)
                view.addSubview(playerView!)
                window.addSubview(view);
                view.backgroundColor = UIColor.clear
                let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(foldPlayerView(_:)))
                view.addGestureRecognizer(gestureRecognizer)
                //set play Button
                playerView?.setPlayButton(isPlaying: isPlaying)
                playerSuperView = view
                //miniPlayerView + animation
                if floatingType == .left{
                    let moveX: CGFloat = 10
                    self.playerView?.controlViewLeadingConstraint.constant += moveX
                }
                else if floatingType == .right{
                    
                }
                
                self.playerView?.layoutIfNeeded()
                
                UIView.animate(withDuration: 0.15, delay: 0.0, options: [.beginFromCurrentState,.curveEaseInOut], animations: {
                    view.backgroundColor = UIColor.init(white: 0.0, alpha: 0.65)
                })
                
            }
        }
    }
    
    private func addPlayerView(_ type: FloatingType){
        let floatingViewFrame = getFloatingViewFrame()
        let frame: CGRect = CGRect(x: floatingViewFrame.origin.x, y: floatingViewFrame.origin.y, width: getScreenWidth(), height: playerButtonWidthHeight)
        
        playerView = PlayerView(frame: frame,type: type)
        playerView?.delegate = delegate
        //        miniPlayerView?.prevMoveButton.isEnabled = WelaaaPlayerMangager.shared.isPrevItem()
        //        miniPlayerView?.nextMoveButton.isEnabled = WelaaaPlayerMangager.shared.isNextItem()
        
        //        miniPlayerView?.delegate = self
    }
    
    func removePlayerView(){
        playerSuperView?.removeFromSuperview()
        playerView = nil
    }
    
    @objc func foldPlayerView(_ sender: UITapGestureRecognizer){
        show()
        removePlayerView()
    }
    
    private func getLocationYInScreen(view: UIView) -> CGFloat{
        return view.center.y / getScreenHeight()
    }

    private func getScreenWidth() -> CGFloat {
        let screenSize = UIScreen.main.bounds
        return screenSize.width
    }
    
    private func getScreenHeight() -> CGFloat {
        let screenSize = UIScreen.main.bounds
        return screenSize.height
    }
}


