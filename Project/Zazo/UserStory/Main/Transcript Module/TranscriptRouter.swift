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
    private let moduleVC: UIViewController
    
    init(forPresenting controller: UIViewController, in parentVC: UIViewController) {
        self.parentVC = parentVC
        self.moduleVC = controller
    }
    
    public func show() {
        parentVC.presentViewController(moduleVC, animated: true, completion: nil)
    }
    
    public func hide() {
        moduleVC.dismissViewControllerAnimated(true, completion: nil)
    }
}