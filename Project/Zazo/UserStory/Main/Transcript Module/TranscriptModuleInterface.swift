//
//  TranscriptModuleInterface.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

@objc public protocol TranscriptModuleDelegate {
    
}

@objc public protocol TranscriptModule {
    
    func present(for friendWithID: String, from view: UIView)
    
}