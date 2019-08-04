//
//  ViewController.swift
//  FloatingPlayer
//
//  Created by SokJinYoung on 23/07/2019.
//  Copyright © 2019 Stone. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        FloatingPlayer.shared.buttonImage.accept("buttonImage")
    }
    
    @IBAction func showBtnTouched(_ sender: Any) {
        FloatingPlayer.shared.showFloatingWindow()
    }
    
    @IBAction func hideBtnTouched(_ sender: Any) {
        FloatingPlayer.shared.hideFloatingWindow()
        FloatingPlayer.shared.buttonImage.accept("buttonImage2")

    }
}
