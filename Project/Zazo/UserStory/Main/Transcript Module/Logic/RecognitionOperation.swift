//
//  RecognitionOperation.swift
//  Zazo
//
//  Created by Server on 27/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

public class RecognitionOperation: ConcurrentOperation {
        
    var result: String?
    var error: NSError?
    
    var fileURL: NSURL
    
    required public init?(url: NSURL)
    {
        self.fileURL = url
    }
}