//
//  PlayerView.swift
//  WelaaaV2
//
//  Created by SokJinYoung on 16/05/2019.
//  Copyright © 2019 Stone. All rights reserved.
//

//import Foundation
import UIKit

//import SDWebImage

public enum PlayerControlEvent{
    case prev
    case next
    case toggle //play, pause
}

enum PlayerViewTags: Int{
    case container = 100, startButton ,prevButton, pausePlayButton, nextButton
}

public protocol PlayerEventDelegate: AnyObject {
    func playerTouched()
    func playerControlBtnTouched(event: PlayerControlEvent)
    func playerCloseBtnTouched()
}

let playerButtonWidthHeight: CGFloat = 43

class PlayerView: UIView{
    weak var delegate: PlayerEventDelegate?
    
    @IBOutlet weak var controlViewLeadingConstraint: NSLayoutConstraint!
    let buttonWidth: CGFloat = playerButtonWidthHeight
    //MARK: Init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //        set()
    }
    
    init(frame: CGRect, type: FloatingType){
        super.init(frame: frame)
        set(type)
    }
    
    func set(_ type: FloatingType){
        //xib connect
        guard let xibName = NSStringFromClass(self.classForCoder).components(separatedBy: ".").last else { return }
        
        let view = (type == .left) ? (Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView) : (Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.last as! UIView)
        
        view.frame = self.bounds
        view.tag = PlayerViewTags.container.rawValue
        self.addSubview(view)
        if let startButton  = self.viewWithTag(PlayerViewTags.startButton.rawValue){
            startButton.layer.cornerRadius = buttonWidth / 2
        }
        self.layoutIfNeeded()
    }
    
    func setStartButtonImage(image: UIImage){
        if let startButton  = self.viewWithTag(PlayerViewTags.startButton.rawValue) as? UIButton{
            startButton.setImage(image, for: .normal)
        }
    }
    
    func setPlayButtonImage(isPlaying: Bool){
//        if isPlaying{
//            playButton.setImage(UIImage.init(named: "miniPause"), for: .normal)
//        }
//        else{
//            playButton.setImage(UIImage.init(named: "miniPlay"), for: .normal)
//        }
    }
    
    func moveAnimation(){
        if let constraints = self.viewWithTag(PlayerViewTags.container.rawValue)?.constraints{
            for c in constraints {
                if c.identifier  == "horizontalSpcWithSafeArea"{
                    c.constant += 10
                    layoutIfNeeded()
                    break
                }
            }
        }
    }
    
    //MARK: Event
    @IBAction func prevBtnTouched(_ sender: Any) {
        delegate?.playerControlBtnTouched(event: .prev)
    }
    
    @IBAction func nextBtnTouched(_ sender: Any) {
        delegate?.playerControlBtnTouched(event: .next)
    }
    
    @IBAction func playPauseBtnTouched(_ sender: Any) {
        delegate?.playerControlBtnTouched(event: .toggle)
    }
    
    @IBAction func playerBtnTouched(_ sender: Any) {
        delegate?.playerTouched()
    }
}
