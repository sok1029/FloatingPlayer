//
//  ViewController.swift
//  FloatingPlayer
//
//  Created by SokJinYoung on 23/07/2019.
//  Copyright © 2019 Stone. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var floatingPlayer = FloatingPlayer.init(imgName:"test.jpg")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func showBtnTouched(_ sender: Any) {
        floatingPlayer.delegate = self
        floatingPlayer.show()
    }
    
    @IBAction func hideBtnTouched(_ sender: Any) {
        floatingPlayer.hide()
    }
}

extension ViewController: PlayerEventDelegate{
    func playerTouched() {
        print("playerTouched")
    }
    
    func playerControlBtnTouched(event: PlayerControlEvent) {
        print("playerControlBtnTouched")
        
    }
    
    func playerCloseBtnTouched() {
        print("playerCloseBtnTouched")
    }
    
}

