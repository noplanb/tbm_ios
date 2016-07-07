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
    
    public func show(from sourceView: UIView) {
        
        let thumbView = moduleVC.contentView.thumbHolder
        
        let originalVCBackground = moduleVC.view.backgroundColor
        
        thumbView.alpha = 0;
        moduleVC.view.backgroundColor = UIColor.clearColor()
        
        parentVC.presentViewController(moduleVC,
                                       animated: false,
                                       completion: {
            
            let originalCenter = thumbView.center
            let centerPoint = sourceView.convertPoint(sourceView.center, toView: self.moduleVC.view)
            thumbView.center = centerPoint
            
            let animations = {
                thumbView.center = originalCenter
                thumbView.alpha = 1;
                self.moduleVC.view.backgroundColor = originalVCBackground
            }
            
            UIView.animateWithDuration(0.6,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.7,
                options: [],
                animations: animations,
                completion: nil)
            
        })
    }
    
    public func hide() {
        moduleVC.dismissViewControllerAnimated(true, completion: nil)
    }
}