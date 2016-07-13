//
//  TranscriptRouter.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

public class TranscriptRouter {
    
    private let parentVC: UIViewController
    private let moduleVC: TranscriptVC
    
    init(forPresenting controller: TranscriptVC, in parentVC: UIViewController) {
        self.parentVC = parentVC
        self.moduleVC = controller
        
        controller.modalPresentationStyle = .OverCurrentContext

    }
    
    public func show(from sourceView: UIView, completion: (Bool -> Void)?) {
        
        let thumbView = moduleVC.contentView.thumbHolder
        
        let originalVCBackground = moduleVC.view.backgroundColor
        
        thumbView.alpha = 0;
        moduleVC.view.backgroundColor = UIColor.clearColor()
        
        let navigationBar = moduleVC.contentView.navigationBar
        
        let completion = {
            
            let navbarTranslate = CGAffineTransformMakeTranslation(0, -navigationBar.bounds.size.height)
            
            navigationBar.transform = navbarTranslate
            
            let sourceAbsolutePoint = sourceView.convertPoint(CGPoint.zero, toView: nil)
            let destinationAbsolutePoint = thumbView.convertPoint(CGPoint.zero, toView: nil)
            
            let thumbTranslate =
                CGAffineTransformMakeTranslation(sourceAbsolutePoint.x - destinationAbsolutePoint.x,
                                                 sourceAbsolutePoint.y - destinationAbsolutePoint.y)
            
            thumbView.transform = thumbTranslate
            
            thumbView.alpha = 1;
            
            let animations = {
            
                thumbView.transform = CGAffineTransformIdentity
                
                navigationBar.transform = CGAffineTransformIdentity
                
                self.moduleVC.view.backgroundColor = originalVCBackground
            }
            
            UIView.animateWithDuration(2,
                                       delay: 0,
                                       usingSpringWithDamping: 1,
                                       initialSpringVelocity: 3,
                                       options: [],
                                       animations: animations,
                                       completion: completion)
            

        }
        
        parentVC.presentViewController(moduleVC,
                                       animated: false,
                                       completion:completion)
        
    }
    
    public func hide() {
        moduleVC.dismissViewControllerAnimated(true, completion: nil)
    }
}