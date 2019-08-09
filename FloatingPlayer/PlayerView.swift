//
//  PlayerView.swift
//  WelaaaV2
//
//  Created by SokJinYoung on 16/05/2019.
//  Copyright © 2019 Stone. All rights reserved.
//

//import Foundation
import UIKit


class PlayerView: UIView{
    
    enum SubView: Int{
        case container = 100

        enum Button: Int, CaseIterable{
            static var allCases: [Button] {
                return [.open, .prev, .pausePlay, .next]
            }
            case open = 101, prev, pausePlay, next
        }
    }

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
            v.tag = SubView.container.rawValue
            return v
        }()
        
        self.addSubview(view)
        
        if let openButton  = self.viewWithTag(SubView.Button.open.rawValue){
            openButton.layer.cornerRadius = fltBtnWidthHeight / 2
        }
    }
    
    func setOpenButtonImage(_ image: UIImage){
        if let openbutton = self.viewWithTag(SubView.Button.open.rawValue) as? UIButton{
            openbutton.setImage(image, for: .normal)
        }
    }
    
    //MARK: -Animation
    func moveAnimation(){
        if let constraints = self.viewWithTag(SubView.container.rawValue)?.constraints{
            for c in constraints {
                if c.identifier  == "horizontalSpcWithSafeArea"{
                    c.constant += 10
                    layoutIfNeeded()
                    break
                }
            }
        }
    }
    
    func getButton(subview: SubView.Button) -> UIButton{
        return self.viewWithTag(subview.rawValue) as! UIButton
    }
    
}
