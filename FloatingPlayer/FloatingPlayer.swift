
//  Created by Ali Pourhadi on 2017-05-07.
//  Copyright © 2019 Stone. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class FloatingPlayer {
    let disposeBag = DisposeBag()

    static let shared: FloatingPlayer = {
        return FloatingPlayer.init()
    }()
    
    private var fltWindow: FloatingWindow!
    private var playerView: PlayerView?
    private var isPlaying: Bool = false
    private var dimBgView: UIView?
    
    lazy var buttonImage = BehaviorRelay<String>(value: "")
    //MARK: -Init
    private init() {
        self.fltWindow = FloatingWindow()
        self.fltWindow.topButton.rx.controlEvent([.touchUpInside])
            .subscribe(onNext: { [weak self]  in
                self?.showPlayer()
            })
            .disposed(by: disposeBag)
        
        self.buttonImage.asObservable().subscribe(onNext: { [weak self] (imgName) in
            if imgName != ""{
                if let img = UIImage.init(named: imgName){
                    self?.fltWindow.topButton.setImage(img, for: .normal)
                }
            }
        }).disposed(by: disposeBag)
    }
    
    
    //MARK: -FloatingWindow
    public func showFloatingWindow() {
        if fltWindow.isHidden {
            fltWindow.makeKeyAndVisible()
            fltWindow.addSubview(fltWindow.topButton)
            fltWindow.isHidden = false
        }
    }
    
    public func hideFloatingWindow() {
        fltWindow.isHidden = true
        fltWindow.topButton.removeFromSuperview()
    }
    
    //MARK: -Player
    private func showPlayer() {
        if !fltWindow.dragging, !fltWindow.isHidden{
            if let appWindow = (UIApplication.shared.delegate as! AppDelegate).window{
                hideFloatingWindow()
               
                //background dimView(=diableView)
                let dimBgView: UIView = {
                    let v = UIView(frame: appWindow.bounds)
                    v.backgroundColor = UIColor.clear
                    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(removePlayer(_:)))
                    v.addGestureRecognizer(gestureRecognizer)
                    return v
                }()
                
                self.dimBgView = dimBgView

                UIView.animate(withDuration: 0.15, delay: 0.0, options: [.beginFromCurrentState,.curveEaseInOut], animations: {
                    dimBgView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.65)
                })
                
                //PlayerView
                 playerView = {
                    let playerView: PlayerView = {
                        let frame: CGRect =  {
                            let p = (fltWindow.convert(fltWindow.topButton.frame.origin, to: appWindow))
                            return CGRect(x: 0, y: p.y, width:  UIScreen.main.bounds.width, height: fltBtnWidthHeight)
                        }()
                        return PlayerView(frame: frame,type: fltWindow.settledDirection)
                    }()
                    //image
                    if let image = fltWindow.topButton.image(for: .normal){
                        playerView.setOpenButtonImage(image)
                    }
                    playerView.setPlayButtonImage(isPlaying: isPlaying)
                    
                    //        miniPlayerView?.prevMoveButton.isEnabled = WelaaaPlayerMangager.shared.isPrevItem()
                    //        miniPlayerView?.nextMoveButton.isEnabled = WelaaaPlayerMangager.shared.isNextItem()
                    
                    //        miniPlayerView?.delegate = self
                    playerView.delegate = fltWindow.rootViewController as! FloatingPlayerViewController
                    
                    return playerView
                }()
                
                self.playerView!.moveAnimation()
                
                appWindow.addSubview(dimBgView);
                dimBgView.addSubview(playerView!)
            }
        }
    }
    
    @objc func removePlayer(_ sender: UITapGestureRecognizer){
        showFloatingWindow()
        dimBgView?.removeFromSuperview()
        playerView = nil
    }
}


