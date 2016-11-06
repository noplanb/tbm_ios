//
//  UIAlertController.swift
//  Zazo
//
//  Created by Rinat on 06/11/2016.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

extension UIAlertController {
    
    func setHideOnApplicationResign() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIAlertController.applicationWillResign), name: UIApplicationWillResignActiveNotification, object: nil)
    }
    
    func applicationWillResign() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillResignActiveNotification, object: nil)
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
