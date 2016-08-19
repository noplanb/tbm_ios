//
//  ComposeRouter.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

public class ComposeRouter: NSObject {
    
    private let parentVC: UIViewController
    private let moduleVC: ComposeVC

    public var isBeingPresented = false

    init(forPresenting controller: ComposeVC, in parentVC: UIViewController) {
        self.parentVC = parentVC
        self.moduleVC = controller
    }
    
    public func show(from sourceView: UIView, completion: (Bool -> Void)?) {
        self.isBeingPresented = true
        parentVC.presentViewController(moduleVC, animated: true, completion: nil)
    }
    
    public func hide() {
        moduleVC.dismissViewControllerAnimated(true, completion: nil)
        self.isBeingPresented = false
    }

}

