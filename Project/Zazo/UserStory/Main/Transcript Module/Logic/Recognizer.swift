//
//  Recognizer.swift
//  Zazo
//
//  Created by Rinat Gabdullin on 27/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

public protocol RecognizerResultHandler {
    
    func handleRecognitionResult(result: RecognitionResult)
    
}

public class Recognizer {
    
    let resultHandler: RecognizerResultHandler
    
    required public init(handler: RecognizerResultHandler) {
        self.resultHandler = handler
    }
    
    func operationForURL(url: NSURL) -> RecognitionOperation? {
        return nil
    }
    
    func canRecognize() -> Bool {
        return false
    }
    
    
}