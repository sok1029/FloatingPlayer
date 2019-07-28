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
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        currentOrientationSubject.onNext(UIDevice.current.orientation)
    }
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
