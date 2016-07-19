//
//  ComposeModuleView.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import SnapKit
import OAStackView

public class ComposeView: UIView {
    
    var constraintsSet = false
    
    override public func updateConstraints() {
        
        super.updateConstraints()
        
        guard let screenWidth = self.window?.bounds.width else {
            return
        }
        
        guard !constraintsSet else {
            return
        }
        
        constraintsSet = true
        

        // Constraints
        
    }
    
}