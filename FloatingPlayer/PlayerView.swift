//
//  PlayerView.swift
//  WelaaaV2
//
//  Created by SokJinYoung on 16/05/2019.
//  Copyright © 2019 Stone. All rights reserved.
//

//import Foundation
import UIKit

public enum PlayerControl{
    case prev
    case next
    case toggle //play, pause
}

enum PlayerSubViews: Int{
    case container = 100, openButton ,prevButton, pausePlayButton, nextButton
}

class PlayerView: UIView{    
    //MARK: -Init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, type: FloatingSettledDirection){
        super.init(frame: frame)
        set(with: type)
    }
    //MARK: -Set
    private func set(with type: FloatingSettledDirection){
        //xib connect
        guard let xibName = NSStringFromClass(self.classForCoder).components(separatedBy: ".").last else { return }
        
        let view: UIView = {
            let v = (type == .left) ?
            (Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView) :
            (Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.last as! UIView)
        
            v.frame = self.bounds
            v.tag = PlayerSubViews.container.rawValue
            return v
        }()
        
        self.addSubview(view)
        
        if let openButton  = self.viewWithTag(PlayerSubViews.openButton.rawValue){
            openButton.layer.cornerRadius = fltBtnWidthHeight / 2
        }
    }
    
    func setOpenButtonImage(_ image: UIImage){
        if let openbutton = self.viewWithTag(PlayerSubViews.openButton.rawValue) as? UIButton{
            openbutton.setImage(image, for: .normal)
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
    //MARK: -Animation
    func moveAnimation(){
        if let constraints = self.viewWithTag(PlayerSubViews.container.rawValue)?.constraints{
            for c in constraints {
                if c.identifier  == "horizontalSpcWithSafeArea"{
                    c.constant += 10
                    layoutIfNeeded()
                    break
                }
            }
        }
    }
    
    func getOpenButton() -> UIButton{
        return self.viewWithTag(PlayerSubViews.openButton.rawValue) as! UIButton
    }
    
    func getPrevButton() -> UIButton{
        return self.viewWithTag(PlayerSubViews.prevButton.rawValue) as! UIButton
    }
    
    func getPausePlayButton() -> UIButton{
        return self.viewWithTag(PlayerSubViews.pausePlayButton.rawValue) as! UIButton
    }
    
    func getNextButton() -> UIButton{
        return self.viewWithTag(PlayerSubViews.nextButton.rawValue) as! UIButton
    }
    
}
