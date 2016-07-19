//
//  KeyboardObserver.swift
//  Zazo
//
//  Created by Rinat on 19/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

protocol KeyboardObserver: class {
    
    func didChangeKeyboardHeight(height: CGFloat)
    func willChangeKeyboardHeight(height: CGFloat)
    
    func startKeyboardObserving()
}

extension KeyboardObserver {
    
    func didChangeKeyboardHeight(height: CGFloat) {
        
    }
    
    func willChangeKeyboardHeight(height: CGFloat) {
        
    }
    
    func startKeyboardObserving() {
        
        let center = NSNotificationCenter.defaultCenter()
        
        center.addObserverForName(UIKeyboardWillHideNotification,
                                  object: nil,
                                  queue: nil) { (notification) in
                                    
                                    self.keyboardWillHide(notification)
        }
        
        center.addObserverForName(UIKeyboardWillShowNotification,
                                  object: nil,
                                  queue: nil) { (notification) in
                                    
                                    self.keyboardWillShow(notification)
                                    
        }
        
        center.addObserverForName(UIKeyboardDidHideNotification,
                                  object: nil,
                                  queue: nil) { (notification) in
                                    
                                    self.keyboardDidHide(notification)
                                    
        }
        
        center.addObserverForName(UIKeyboardDidShowNotification,
                                  object: nil,
                                  queue: nil) { (notification) in
                                    
                                    self.keyboardDidShow(notification)
        }
    }
    
    func finishKeyboardObserving() {
        
        let center = NSNotificationCenter.defaultCenter()
        
        let names = [UIKeyboardWillHideNotification,
                     UIKeyboardWillShowNotification,
                     UIKeyboardDidHideNotification,
                     UIKeyboardDidShowNotification]
        
        for name in names {
            center.removeObserver(self, name: name, object: nil)
        }
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.willChangeKeyboardHeight(heightFromNotification(notification))
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.willChangeKeyboardHeight(CGFloat(0))
    }
    
    func keyboardDidShow(notification: NSNotification) {
        self.didChangeKeyboardHeight(heightFromNotification(notification))
    }
    
    func keyboardDidHide(notification: NSNotification) {
        self.willChangeKeyboardHeight(CGFloat(0))
    }
    
    func heightFromNotification(notification: NSNotification) -> CGFloat {
        
        let object = notification.userInfo![UIKeyboardFrameEndUserInfoKey]
        
        guard let frame = object as? NSValue else {
            return 0
        }
        
        let height = frame.CGRectValue().size.height
        
        return height
    }
}