//
//  MiniFloatingPlayerViewController.swift
//  MiniFloatingPlayer
//
//  Created by SokJinYoung on 26/07/2019.
//  Copyright © 2019 Stone. All rights reserved.
//

import UIKit
import RxSwift

enum DeviceOrientationChange{
    case will, did
}

class FloatingPlayerViewController: UIViewController {
    
    var deviceOriChangedSubject = PublishSubject<DeviceOrientationChange>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
       
        deviceOriChangedSubject.onNext(DeviceOrientationChange.will)
       
        coordinator.animateAlongsideTransition(in: nil, animation: { (a) in
        }) { [weak self] (b) in
            self?.deviceOriChangedSubject.onNext(DeviceOrientationChange.did)
        }
    }
}

extension FloatingPlayerViewController: PlayerEventDelegate{
    func playerTouched() {
            print("playerTouched")
    }

    func playerControlBtnTouched(event: PlayerControlEvent) {
        print("playerControlBtnTouched")
    }

}
