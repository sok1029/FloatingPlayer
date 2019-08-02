//
//  ViewController.swift
//  FloatingPlayer
//
//  Created by SokJinYoung on 23/07/2019.
//  Copyright © 2019 Stone. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var floatingPlayer = FloatingPlayer.init(imgName:"buttonImage.jpg")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func showBtnTouched(_ sender: Any) {
        floatingPlayer.floatingWindowShow()
    }
    
    @IBAction func hideBtnTouched(_ sender: Any) {
        floatingPlayer.floatingWindowHide()
    }
}
