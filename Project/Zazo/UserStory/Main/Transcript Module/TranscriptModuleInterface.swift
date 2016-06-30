//
//  TranscriptModuleInterface.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

protocol TranscriptModuleDelegate {
    
}

protocol TranscriptModule {
    
    func present(for friendWithID: String)
    
}