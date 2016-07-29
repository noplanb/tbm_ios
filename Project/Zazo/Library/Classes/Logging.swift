//
//  Logging.swift
//  Zazo
//
//  Created by Server on 27/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

func logInfo(string: String,
             _ file: String = #file,
               methodName: String = #function) {
    
    OBLogger.instance().info("\(file)(\(methodName)): \(string)")
}

func logWarning(string: String,
                _ file: String = #file,
                  methodName: String = #function) {
    
    OBLogger.instance().info("\(file)(\(methodName)): ⚠️ \(string)")
}

func logError(string: String,
              _ file: String = #file,
                methodName: String = #function) {
    
    let url = NSURL(string: file)!
    let filename = url.lastPathComponent ?? ""
    
    OBLogger.instance().info("\(filename)(\(methodName)): 🚫 \(string)")
}