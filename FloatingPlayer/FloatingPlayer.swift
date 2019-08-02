
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
    private var dimBgView: UIView?

    init(imgName: String? = nil) {
        self.fltWindow = FloatingWindow()
        self.fltWindow.topButton.rx.controlEvent([.touchUpInside])
            .subscribe(onNext: { [weak self]  in
                self?.showPlayer()
            })
            .disposed(by: disposeBag)

        if let imgName = imgName, let image = UIImage(named: imgName) {
            self.fltWindow.topButton.setImage(image, for: .normal)
        }
    }
    
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
                
                //playerView
                 playerView = {
                        let frame: CGRect =  {
                            let point = (fltWindow.convert(fltWindow.topButton.frame.origin, to: appWindow))
                            return CGRect(x: 0, y: point.y, width:  UIScreen.main.bounds.width, height: fltBtnWidthHeight)
                        }()
                        
                        let playerView = PlayerView(frame: frame,type: fltWindow.settledDirection)
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
        self.playerView = nil
        
    }
}


