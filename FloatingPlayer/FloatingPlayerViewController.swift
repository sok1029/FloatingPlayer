//
//  MiniFloatingPlayerViewController.swift
//  MiniFloatingPlayer
//
//  Created by SokJinYoung on 26/07/2019.
//  Copyright © 2019 Stone. All rights reserved.
//

import UIKit
import RxSwift

enum DeviceOrientationTransition{
    case will, did
}

class FloatingPlayerViewController: UIViewController {
    var deviceOriTransitionSubject = PublishSubject<DeviceOrientationTransition>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
       
        deviceOriTransitionSubject.onNext(DeviceOrientationTransition.will)
        coordinator.animateAlongsideTransition(in: nil, animation: { (a) in
        }) { [weak self] (b) in
            self?.deviceOriTransitionSubject.onNext(DeviceOrientationTransition.did)
        }
    }
}
