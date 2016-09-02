//
//  ComposeModuleVC.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

public class ComposeVC: UIViewController, ComposeUIInput, KeyboardObserver {
    
    weak var output: ComposeUIOutput?
    
    public lazy var contentView: ComposeView = ComposeView()
    
    let textViewDelegate = ComposeTextViewDelegate()
    
    // MARK: VC overrides
    
    override public func viewDidLoad() {
        
        startKeyboardObserving()
        contentView.elements.textField.delegate = textViewDelegate
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(self.cancelTap))
        contentView.elements.navigationBar.pushNavigationItem(self.navigationItem, animated: false)
        
        contentView.elements.sendButton.addTarget(self, action: #selector(ComposeVC.sendTap), forControlEvents: .TouchUpInside)
        
    }
    
    override public func loadView() {
        view = contentView
    }
    
    public override func viewWillAppear(animated: Bool) {
        contentView.elements.sendButton.alpha = 0
        contentView.elements.keyboardButton.alpha = 0
    }
    
    public override func viewDidAppear(animated: Bool) {
        contentView.elements.textField.becomeFirstResponder()
    }
    
    public override func viewDidDisappear(animated: Bool) {
        finishKeyboardObserving()
    }
    // MARK: Input
    
    func typedText() -> String {
        return contentView.elements.textField.text
    }
    
    func showLoading(loading: Bool) {
        if loading {
            SVProgressHUD.show()
        }
        else {
            SVProgressHUD.dismiss()
        }
    }
    
    func showFriendName(name: String) {
        self.navigationItem.title = name
    }
    
    func askForRetry(text: String?, completion: (Bool) -> ()) {
        let alert = UIAlertController(title: "Message wasn't sent", message: text, preferredStyle: .Alert)
        
        let completion: ((UIAlertAction) -> Void) = { completion($0.style != .Cancel) }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: completion))
        alert.addAction(UIAlertAction(title: "Retry", style: .Default, handler: completion))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: Events
    
    func cancelTap() {
        output!.didTapCancel()
    }

    func sendTap() {
        output?.didTapSend()
    }
    
    // MARK: KeyboardObserver
    
    func willChangeKeyboardHeight(height: CGFloat) {
        contentView.bottomSpacer.snp_updateConstraints { (make) in
            make.height.equalTo(height)
        }
        
        UIView.animateWithDuration(1) { 
            self.contentView.elements.sendButton.alpha = 1
            
//            self.contentView.elements.keyboardButton.alpha = 1
        }
    }
}