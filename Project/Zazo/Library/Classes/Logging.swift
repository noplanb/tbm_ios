//
//  Logging.swift
//  Zazo
//
//  Created by Server on 27/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

func logInfo(string: String, _ file: String = #file, line: Int = #line) {
    OBLogger.instance().info("\(file)(\(line)): \(string)")
}

func logWarning(string: String, _ file: String = #file, line: Int = #line) {
    OBLogger.instance().info("\(file)(\(line)): ⚠️ \(string)")
}

func logError(string: String, _ file: String = #file, line: Int = #line) {
    
    let url = NSURL(string: file)!
    let filename = url.lastPathComponent ?? ""
    
    OBLogger.instance().info("\(filename)(\(line)): 🚫 \(string)")
}