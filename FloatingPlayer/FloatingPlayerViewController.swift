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
    //    let disposeBag = DisposeBag()
    var currentOrientationSubject = PublishSubject<UIDeviceOrientation>()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        currentOrientationSubject.onNext(UIDevice.current.orientation)
    }
}

