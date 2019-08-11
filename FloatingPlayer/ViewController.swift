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
    
        FloatingPlayer.shared.buttonImg.accept("buttonImage")
        FloatingPlayer.shared.setImages(("pause","play","prev","next"))
        FloatingPlayer.shared.isPlaying.accept(false)

        FloatingPlayer.shared.setEventHandler(open: {
            //input your openButton Act
            print("openButton Act")
        },
        prev: {
            //input your prevButton Act
            print("prevButton act")
        },
        next: {
            //input your nextButton Act
            print("nextButton act")
        },
        pause: {
            //input your pauseButton Act
            print("pauseButton act")
        }) {
            //input your playButton Act
            print("playButton act")
        }
    }
    
    @IBAction func showBtnTouched(_ sender: Any) {
        FloatingPlayer.shared.showFloating()
    }
    
    @IBAction func hideBtnTouched(_ sender: Any) {
        FloatingPlayer.shared.hideFloating()
    }
}
