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

public protocol PlayerEventDelegate: AnyObject {
    func playerTouched()
    func playerControlBtnTouched(event: PlayerControlEvent)
    func playerCloseBtnTouched()
}

let playerButtonWidthHeight: CGFloat = 43

class PlayerView: UIView{
    weak var delegate: PlayerEventDelegate?
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var prevMoveButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nextMoveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var controlView: UIView!
    
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
        self.addSubview(view)
        startButton.layer.cornerRadius = buttonWidth / 2
        self.layoutIfNeeded()
    }
    
    func setImage(image: UIImage){
        self.startButton.setImage(image, for: .normal)
    }
    
    func setPlayButton(isPlaying: Bool){
        if isPlaying{
            playButton.setImage(UIImage.init(named: "miniPause"), for: .normal)
        }
        else{
            playButton.setImage(UIImage.init(named: "miniPlay"), for: .normal)
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
    
    @IBAction func closeBtnTouched(_ sender: Any) {
        delegate?.playerCloseBtnTouched()
    }
    
    @IBAction func playerBtnTouched(_ sender: Any) {
        delegate?.playerTouched()
    }
}
