//
//  ComposeModuleVC.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

public class ComposeVC: UIViewController, ComposeUIInput {
    
    var output: ComposeUIOutput?
    
    public lazy var contentView = ComposeView()
    
    // MARK: VC overrides
    
    override public func viewDidLoad() {
        
    }
    
    override public func loadView() {
        view = contentView
    }
    
}