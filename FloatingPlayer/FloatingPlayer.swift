
//  Created by Ali Pourhadi on 2017-05-07.
//  Copyright © 2019 Stone. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

enum FloatingSettledDirection{
    case left, right
}

class FloatingWindow : UIWindow {
    let disposeBag = DisposeBag()
    let appWindow: UIWindow! = UIApplication.shared.keyWindow

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

    var locationYInAppWindow: CGFloat {
        return self.center.y / UIScreen.main.bounds.height
    }
    var settledDirection: FloatingSettledDirection = .left
    var settledCenterPoint: CGPoint  {
        let halfWidthOfWindow = topButton.frame.size.width / 2.0
        let centerX = (settledDirection == .left) ? halfWidthOfWindow : UIScreen.main.bounds.width - halfWidthOfWindow
        let centerY = locationYInAppWindow * UIScreen.main.bounds.height
        return CGPoint(x: centerX, y: centerY)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        let frame = {
            return CGRect(origin: CGPoint(x: 0, y: UIScreen.main.bounds.height / 2.0), size: CGSize(width: playerButtonWidthHeight, height: playerButtonWidthHeight))
        }()
        super.init(frame: frame)
        self.rootViewController = FloatingPlayerViewController()
        self.windowLevel = .normal
        self.backgroundColor = .clear
        self.makeKeyAndVisible()
        self.addSubview(topButton)
        
        if let fltPlayerVC = self.rootViewController as? FloatingPlayerViewController{
            fltPlayerVC.deviceOriChangedSubject.subscribe(onNext: { [weak self] (change) in
                guard let sSelf = self else{ return}
                switch change{
                    case .will:
                        sSelf.alpha = 0
                    case .did:
                        sSelf.alpha = 1
                        sSelf.center  = sSelf.settledCenterPoint
                }
            }).disposed(by: disposeBag)
        }
    }
    
    @objc func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        if panGesture.state == .began {
            dragging = true
        }
        else if panGesture.state == .ended {
            let location = panGesture.location(in: topButton)
            let point = getCenterPoint(with: location)
            let viewHalfWidth = topButton.frame.size.width / 2.0
            
            let isOverHalf = point.x <  UIScreen.main.bounds.width / 2.0 ? false : true
            settledDirection = isOverHalf ? .right : .left
//            fltLocYInScreen = getLocationYInScreen(view: fltWindow)
            
            //left,right decision
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.beginFromCurrentState,.curveEaseInOut], animations: { [weak self] in
                guard let sSelf = self else {return}
                sSelf.center = isOverHalf ?
                    CGPoint(x: UIScreen.main.bounds.width - viewHalfWidth, y: point.y):
                    CGPoint(x: viewHalfWidth, y: point.y)
            })
        }
        else if panGesture.state == .changed {
            let location = panGesture.location(in: topButton)
            print(location)

            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.beginFromCurrentState,.curveEaseInOut], animations: {[weak self] in
                guard let sSelf = self else{return}
                sSelf.center = sSelf.getCenterPoint(with: location)
            })
        }
    }
    
    private func getCenterPoint(with location: CGPoint) -> CGPoint{
        var centerPoint: CGPoint = self.convert(location, to: appWindow)
        //limit
        let viewHalfHeight = topButton.frame.size.height / 2.0
        let topInset = appWindow.safeAreaInsets.top
        let bottomInset = appWindow.safeAreaInsets.bottom
        //        let tapbbarHeight: CGFloat = 49.0
        let topLimitY = topInset + viewHalfHeight
        let bottomLimitY = UIScreen.main.bounds.height - bottomInset - viewHalfHeight
        
        if centerPoint.y > bottomLimitY{
            centerPoint = CGPoint(x: centerPoint.x, y: bottomLimitY)
        }
        else if centerPoint.y < topLimitY{
            centerPoint = CGPoint(x: centerPoint.x, y: topLimitY)
        }
        
        return centerPoint
    }
}

public class FloatingPlayer {
    let disposeBag = DisposeBag()

    private var fltWindow: FloatingWindow!
    private var playerView: PlayerView?
    private var isPlaying: Bool = false
    private var playerBgView: UIView?


    init(imgName: String? = nil) {
        self.fltWindow = FloatingWindow()
//        self.fltWindow.addTopButton()
        self.fltWindow.topButton.rx.controlEvent([.touchUpInside])
            .subscribe(onNext: { [weak self]  in
                self?.playerBtnTouched()
            })
            .disposed(by: disposeBag)

        if let imgName = imgName{
            let image = UIImage(named: imgName)
            self.fltWindow.topButton.setImage(image, for: .normal)
        }
    }
    
    public func floatingWindowShow() {
        if fltWindow.isHidden {
            fltWindow.makeKeyAndVisible()
    //        fltWindow.addSubview(fltButton)
            fltWindow.isHidden = false
        }
    }
    
    public func floatingWindowHide() {
        fltWindow.isHidden = true
    }

    private func playerBtnTouched(){
        if !fltWindow.dragging{
            playerControllerShow()
        }
        fltWindow.dragging = false
    }
    
    private func playerControllerShow() {
        if !fltWindow.isHidden{
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if let window = appDelegate.window{
                floatingWindowHide()
                
                //background diableView
                let bgView = UIView(frame: window.bounds)
                window.addSubview(bgView);
                bgView.backgroundColor = UIColor.clear
                let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(foldPlayerView(_:)))
                bgView.addGestureRecognizer(gestureRecognizer)
                playerBgView = bgView
                
                UIView.animate(withDuration: 0.15, delay: 0.0, options: [.beginFromCurrentState,.curveEaseInOut], animations: {
                    bgView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.65)
                })
                
                //playerView
                 playerView = {
                        let frame: CGRect =  {
                            let point = (fltWindow.topButton.convert(fltWindow.topButton.frame.origin, to: UIApplication.shared.keyWindow))
                            let fltViewFrame = CGRect(x: point.x, y: point.y, width: fltWindow.topButton.frame.width, height: fltWindow.topButton.frame.height)
                            return CGRect(x: 0, y: fltViewFrame.origin.y, width:  UIScreen.main.bounds.width, height: playerButtonWidthHeight)
                        }()
                        
                        let playerView = PlayerView(frame: frame,type: fltWindow.settledDirection)
                        //image
                        if let image = fltWindow.topButton.image(for: .normal){
                            playerView.setStartButtonImage(image: image)
                        }
                        playerView.setPlayButtonImage(isPlaying: isPlaying)
                        
                        //        miniPlayerView?.prevMoveButton.isEnabled = WelaaaPlayerMangager.shared.isPrevItem()
                        //        miniPlayerView?.nextMoveButton.isEnabled = WelaaaPlayerMangager.shared.isNextItem()
                        
                        //        miniPlayerView?.delegate = self
                        playerView.delegate = fltWindow.rootViewController as! FloatingPlayerViewController
                        
                        return playerView
                }()
                
                self.playerView!.moveAnimation()
                bgView.addSubview(playerView!)
            }
        }
    }
    
    func removePlayerView(){
        playerBgView?.removeFromSuperview()
        self.playerView = nil
    }
    
    @objc func foldPlayerView(_ sender: UITapGestureRecognizer){
        floatingWindowShow()
        removePlayerView()
    }
}


