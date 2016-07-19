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
        
    init(forPresenting controller: ComposeVC, in parentVC: UIViewController) {
        self.parentVC = parentVC
        self.moduleVC = controller
        
        controller.modalPresentationStyle = .Custom
    }
    
    public func show(from sourceView: UIView, completion: (Bool -> Void)?) {
        
    }
    
    public func hide() {
        moduleVC.dismissViewControllerAnimated(true, completion: nil)
    }
    

}

