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
        FloatingPlayer.shared.setPlayPauseImages(("pause","play"))
        FloatingPlayer.shared.isPlaying.accept(false)

        FloatingPlayer.shared.setEventHandler(open: {
            print("openButton do")
        },
        prev: {
            print("prevButton do")
        },
        next: {
            print("nextButton do")
        },
        pause: {
            print("pauseButton do")
        }) {
            print("playButton do")
        }
        
    }
    
    @IBAction func showBtnTouched(_ sender: Any) {
        FloatingPlayer.shared.showFloatingWindow()
    }
    
    @IBAction func hideBtnTouched(_ sender: Any) {
        FloatingPlayer.shared.hideFloatingWindow()
    }
}
