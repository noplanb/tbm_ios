//
//  ComposeModuleVC.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

public class ComposeVC: UIViewController, ComposeUIInput, KeyboardObserver {
    
    var output: ComposeUIOutput?
    
    public lazy var contentView: ComposeView = ComposeView()
    
    let textViewDelegate = ComposeTextViewDelegate()
    
    // MARK: VC overrides
    
    override public func viewDidLoad() {
        startKeyboardObserving()
        contentView.elements.textField.delegate = textViewDelegate
    }
    
    override public func loadView() {
        view = contentView
    }
    
    public override func viewDidAppear(animated: Bool) {
        contentView.elements.textField.becomeFirstResponder()
    }

    // MARK: KeyboardObserver
    
    func willChangeKeyboardHeight(height: CGFloat) {
        contentView.bottomSpacer.snp_updateConstraints { (make) in
            make.height.equalTo(height)
        }
    }
}