
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
    var isPlaying = BehaviorRelay<Bool>(value: false)

    private var dimBgView: UIView?
    
    private var handlers: (open: () -> (), prev: () -> (), next: () -> (), pause: () -> (), play: () -> ())?
    private var imgs: (pause: String, play: String, prev: String, next: String)?
    
    lazy var buttonImg = BehaviorRelay<String>(value: "")
    
    //MARK: -Init
    private init() {
        self.fltWindow = FloatingWindow()
        self.fltWindow.topButton.rx.controlEvent([.touchUpInside])
            .subscribe(onNext: { [weak self]  in
                self?.showPlayer()
            })
            .disposed(by: disposeBag)
        
        self.buttonImg.asObservable().subscribe(onNext: { [weak self] (imgName) in
            if imgName != ""{
                if let img = UIImage.init(named: imgName){
                    self?.fltWindow.topButton.setImage(img, for: .normal)
                }
            }
        }).disposed(by: disposeBag)
        
        isPlaying.asObservable().subscribe(onNext: { [weak self] (isPlaying) in
            guard let sSelf = self else { return }
            
            if let imgs = sSelf.imgs{
                let img = isPlaying ? (UIImage(named: imgs.pause)) : (UIImage(named: imgs.play))
                sSelf.playerView?.getButton(subview: .pausePlay).setImage(img, for: .normal)
            }
            
            if let handlers = sSelf.handlers{
                isPlaying ? handlers.play() : handlers.pause()
            }
        }).disposed(by: disposeBag)
    }
    
    //MARK -Event
    func setEventHandler(open:  @escaping () -> (), prev: @escaping () -> (), next: @escaping () -> (), pause: @escaping () -> (), play: @escaping () -> () ){
        handlers = (open: open, prev: prev, next: next, pause: pause, play: play)
    }
    //MARK - PlayPauseimages
    func setImages(_ images: (pause: String, play: String, prev: String, next: String)){
        imgs = images
    }
    
    //MARK: -FloatingWindow
    public func showFloating() {
        if fltWindow.isHidden {
            fltWindow.makeKeyAndVisible()
            fltWindow.addSubview(fltWindow.topButton)
            fltWindow.isHidden = false
        }
    }
    
    public func hideFloating() {
        fltWindow.isHidden = true
        fltWindow.topButton.removeFromSuperview()
    }
    
    //MARK: -Player
    private func showPlayer() {
        if !fltWindow.dragging, !fltWindow.isHidden{
            if let appWindow = (UIApplication.shared.delegate as! AppDelegate).window{
                hideFloating()
               
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
                    if let img = fltWindow.topButton.image(for: .normal){
                        playerView.setOpenButtonImage(img)
                    }
                    //event
                    for button in PlayerView.SubView.Button.allCases{
                        playerView.getButton(subview: button).rx.controlEvent([.touchUpInside])
                            .subscribe(onNext:{ [weak self] in
                            guard let sSelf = self else { return }
                            switch button{
                            case .open: sSelf.handlers?.open()
                            case .prev: sSelf.handlers?.prev()
                            case .next: sSelf.handlers?.next()
                            case .pausePlay: { sSelf.isPlaying.accept(!sSelf.isPlaying.value) }()
                            }
                        })
                        .disposed(by: disposeBag)
                    }
                    return playerView
                }()
                
                isPlaying.accept(isPlaying.value)
                self.playerView!.moveAnimation()
                
                appWindow.addSubview(dimBgView);
                dimBgView.addSubview(playerView!)
            }
        }
    }
    
    @objc func removePlayer(_ sender: UITapGestureRecognizer){
        showFloating()
        dimBgView?.removeFromSuperview()
        playerView = nil
    }
}


