//
//  DimLayerSwRevealView.swift
//  VegetationApp
//
//  Created by Nitin Bhatia on 26/03/19.
//  Copyright © 2019 Nitin Bhatia. All rights reserved.
//

import Foundation
import UIKit

private let DimmingViewTag = 10001

extension UIViewController: SWRevealViewControllerDelegate {
    
    func setupMenuGestureRecognizer() {
        
        revealViewController().delegate = self
        
        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
        self.revealViewController().rearViewRevealWidth = self.view.frame.width - 64

    }
    
    public func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
        self.view.endEditing(true)
        
        if case .right = position {
            let dimmingView = UIView(frame: view.frame)
            dimmingView.tag = DimmingViewTag
            dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            view.addSubview(dimmingView)
            view.bringSubviewToFront(dimmingView)
            dimmingView.addGestureRecognizer(revealViewController().panGestureRecognizer())
            dimmingView.addGestureRecognizer(revealViewController().tapGestureRecognizer())
            
        } else {
            view.viewWithTag(DimmingViewTag)?.removeFromSuperview()
        }
    }
    
    //MARK: - SWRevealViewControllerDelegate
    
    //    public func revealController(_ revealController: SWRevealViewController!, didMoveTo position: FrontViewPosition) {
    //         if case .right = position {
    //
    //            let dimmingView = UIView(frame: view.frame)
    //            dimmingView.tag = DimmingViewTag
    //            dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    //            view.addSubview(dimmingView)
    //            view.bringSubview(toFront: dimmingView)
    //           dimmingView.addGestureRecognizer(revealViewController().panGestureRecognizer())
    //            dimmingView.addGestureRecognizer(revealViewController().tapGestureRecognizer())
    //
    //        } else {
    //            view.viewWithTag(DimmingViewTag)?.removeFromSuperview()
    //        }
    //    }
    
    
}
