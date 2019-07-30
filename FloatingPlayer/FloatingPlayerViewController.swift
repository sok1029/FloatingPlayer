//
//  MiniFloatingPlayerViewController.swift
//  MiniFloatingPlayer
//
//  Created by SokJinYoung on 26/07/2019.
//  Copyright © 2019 Stone. All rights reserved.
//

import UIKit
import RxSwift

class FloatingPlayerViewController: UIViewController {
    var floatingPlayer: FloatingPlayer!
    var currentOrientationSubject = PublishSubject<UIDeviceOrientation>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.floatingPlayer.fltWindow.alpha = 0
        coordinator.animateAlongsideTransition(in: nil, animation: { (a) in
        }) { [weak self] (b) in
            self?.currentOrientationSubject.onNext(UIDevice.current.orientation)
        }
    }
}

