
//  Created by Ali Pourhadi on 2017-05-07.
//  Copyright © 2019 Stone. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

enum FloatingType{
    case left, right
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

    private var fltWindow: FloatingWindow!
    private var appWindow: UIWindow!
    private var fltButton: UIButton!

    private var isPlaying: Bool = false
    private var dragging: Bool = false
    private var isShowing = false

    private var playerSuperView: UIView?
    private var playerView: PlayerView?
    
    private var fltPlayerViewController: FloatingPlayerViewController?
    
    private var fltType: FloatingType = .left
    private var fltLocYInScreen: CGFloat = 0

    var delegate: PlayerEventDelegate?

    public init(imgName: String? = nil) {
        self.appWindow = UIApplication.shared.keyWindow
        //Button
        self.fltButton = {
            let button = UIButton(type: UIButton.ButtonType.custom)
            button.backgroundColor = .lightGray
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
            
            if let imgName = imgName{
                let image = UIImage(named: imgName)
                button.setImage(image, for: .normal)
            }
            return button
        }()
        
        //floatingWindow
        makeFloatingView(with: fltButton)
        
        //floatinPlayerViewController
        fltPlayerViewController?.deviceOriChangedSubject.subscribe(onNext: { [weak self] (change) in
            guard let sSelf = self else{ return}
            
            switch change{
                case .will:
                    sSelf.fltWindow.alpha = 0
                case .did:
                    sSelf.fltWindow.alpha = 1
                    sSelf.fltWindow.center  = sSelf.getSettledFloatingWindowCenterPoint()
            }
            
        }).disposed(by: disposeBag)
    }
    
    private func makeFloatingView(with button: UIButton){
        let window =  FloatingWindow(frame: CGRect.init(origin: CGPoint(x: 0, y: getScreenHeight() / 2), size: button.frame.size))
      
        fltPlayerViewController = FloatingPlayerViewController()
        
        window.rootViewController = fltPlayerViewController
        window.topView = button
        window.windowLevel = .normal
        window.backgroundColor = .clear
        fltLocYInScreen = getLocationYInScreen(view: window)
        fltWindow = window
    }
    
    public func floatingWindowShow() {
        if isShowing { return }
        fltWindow.makeKeyAndVisible()
        fltWindow.addSubview(fltButton)
        isShowing = true
        fltWindow.isHidden = false
    }
    
    public func floatingWindowHide() {
        self.isShowing = false
        fltWindow.isHidden = true
    }
    
    @objc private func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        if panGesture.state == .began {
            dragging = true
        }
        else if panGesture.state == .ended {
            let location = panGesture.location(in: fltButton)
            let point = getFloatingWindowCenterPoint(with: location)
            let viewHalfWidth = fltButton.frame.size.width / 2.0
            
            let isOverHalf = point.x < getScreenWidth() / 2.0 ? false : true
            fltType = isOverHalf ? .right : .left
            fltLocYInScreen = getLocationYInScreen(view: fltWindow)

            //left,right decision
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.beginFromCurrentState,.curveEaseInOut], animations: { [weak self] in
                guard let sSelf = self else {return}
                sSelf.fltWindow.center = isOverHalf ?
                    CGPoint(x: sSelf.getScreenWidth() - viewHalfWidth, y: point.y):
                    CGPoint(x: viewHalfWidth, y: point.y)
            })
        }
        else if panGesture.state == .changed {
            let location = panGesture.location(in: fltButton)
            
            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.beginFromCurrentState,.curveEaseInOut], animations: {[weak self] in
                guard let sSelf = self else{return}
                let point = sSelf.getFloatingWindowCenterPoint(with: location)
                sSelf.fltWindow.center = point
            })
        }
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
                floatingWindowHide()
                
                //background diableView
                let bgView = UIView(frame: window.bounds)
                window.addSubview(bgView);
                bgView.backgroundColor = UIColor.clear
                let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(foldPlayerView(_:)))
                bgView.addGestureRecognizer(gestureRecognizer)
                playerSuperView = bgView
                
                UIView.animate(withDuration: 0.15, delay: 0.0, options: [.beginFromCurrentState,.curveEaseInOut], animations: {
                    bgView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.65)
                })
                
                //playerView
                self.playerView = {
                    let frame: CGRect =  {
                        let point = (fltButton.convert(fltButton.frame.origin, to: self.appWindow))
                        let floatingViewFrame = CGRect(x: point.x, y: point.y, width: fltButton.frame.width, height: fltButton.frame.height)
                        return CGRect(x: 0, y: floatingViewFrame.origin.y, width: getScreenWidth(), height: playerButtonWidthHeight)
                    }()
                    
                    let playerView = PlayerView(frame: frame,type: fltType)
                    //image
                    if let image = fltButton.image(for: .normal){
                        playerView.setStartButtonImage(image: image)
                    }
                    playerView.setPlayButtonImage(isPlaying: isPlaying)

                    //        miniPlayerView?.prevMoveButton.isEnabled = WelaaaPlayerMangager.shared.isPrevItem()
                    //        miniPlayerView?.nextMoveButton.isEnabled = WelaaaPlayerMangager.shared.isNextItem()
                    
                    //        miniPlayerView?.delegate = self
                    playerView.delegate = delegate

                    return playerView
                }()
          
                if let playerView = self.playerView{
                    playerView.moveAnimation()
                    bgView.addSubview(playerView)
                }
            }
        }
    }
    
    func removePlayerView(){
        playerSuperView?.removeFromSuperview()
        playerView = nil
    }
    
    @objc func foldPlayerView(_ sender: UITapGestureRecognizer){
        floatingWindowShow()
        removePlayerView()
    }
    
    private func getLocationYInScreen(view: UIView) -> CGFloat{
        return view.center.y / getScreenHeight()
    }

    private func getFloatingWindowCenterPoint(with location: CGPoint) -> CGPoint{
        var centerPoint: CGPoint = fltWindow.convert(location, to: appWindow)
        //limit
        let viewHalfHeight = fltButton.frame.size.height / 2.0
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
        let halfWidthOfWindow = fltWindow.topView.frame.size.width / 2.0
        let centerX = (fltType == .left) ? halfWidthOfWindow : getScreenWidth() - halfWidthOfWindow
        let centerY = fltLocYInScreen * getScreenHeight()
        
        return CGPoint(x: centerX, y: centerY)
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


