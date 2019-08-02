
//  Created by Ali Pourhadi on 2017-05-07.
//  Copyright © 2019 Stone. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class FloatingPlayer {
    let disposeBag = DisposeBag()

    private var fltWindow: FloatingWindow!
    private var playerView: PlayerView?
    private var isPlaying: Bool = false
    private var playerBgView: UIView?

    init(imgName: String? = nil) {
        self.fltWindow = FloatingWindow()
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
            fltWindow.addSubview(fltWindow.topButton)
            fltWindow.isHidden = false
        }
    }
    
    public func floatingWindowHide() {
        fltWindow.isHidden = true
        fltWindow.topButton.removeFromSuperview()
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
                            let point = (fltWindow.convert(fltWindow.topButton.frame.origin, to: window))

                            return CGRect(x: 0, y: point.y, width:  UIScreen.main.bounds.width, height: playerButtonWidthHeight)
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
    
   
    
    @objc func foldPlayerView(_ sender: UITapGestureRecognizer){
        floatingWindowShow()
        removePlayerView()
    }
    func removePlayerView(){
        playerBgView?.removeFromSuperview()
        self.playerView = nil
    }
}


